# Configure the OpenStack Provider
provider "openstack" {
  auth_url    = "${var.openstack_auth_url}"
  password    = "${var.openstack_password}"
  tenant_name = "${var.openstack_tenant_name}"
  user_name   = "${var.openstack_user_name}"
}

# Create Keypair
resource "openstack_compute_keypair_v2" "keypair" {
  name       = "${var.prefix}-keypair"
  public_key = "${file(var.openstack_compute_keypair_public_key)}"
}

# Create Security Group
resource "openstack_compute_secgroup_v2" "secgroup" {
  name        = "${var.prefix}-secgroup"
  description = "Security Group got training-lab for ${var.prefix}"

  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

data "openstack_networking_network_v2" "external_network" {
  name = "${var.openstack_networking_network_external_network_name}"
}

# Create private network
resource "openstack_networking_network_v2" "private-network" {
  count          = "${var.environment_count}"
  name           = "${format("%s-%02d-priv-network", var.prefix, count.index + 1)}"
  admin_state_up = "true"
}

# Create private subnet
resource "openstack_networking_subnet_v2" "private-subnet" {
  count           = "${var.environment_count}"
  name            = "${format("%s-%02d-priv-subnet", var.prefix, count.index + 1)}"
  network_id      = "${element(openstack_networking_network_v2.private-network.*.id, count.index)}"
  cidr            = "${var.openstack_networking_subnet_cidr}"
  dns_nameservers = "${var.openstack_networking_subnet_dns_nameservers}"
  enable_dhcp     = true
}

# Create router for private subnet
resource "openstack_networking_router_v2" "private-router" {
  count               = "${var.environment_count}"
  name                = "${format("%s-%02d-priv-router", var.prefix, count.index + 1)}"
  external_network_id = "${data.openstack_networking_network_v2.external_network.id}"
  admin_state_up      = "true"
}

# Create router interface for private subnet
resource "openstack_networking_router_interface_v2" "router-interface" {
  count     = "${var.environment_count}"
  router_id = "${element(openstack_networking_router_v2.private-router.*.id, count.index)}"
  subnet_id = "${element(openstack_networking_subnet_v2.private-subnet.*.id, count.index)}"
}

# Create floating IP for nodes
resource "openstack_networking_floatingip_v2" "floatingip" {
  count = "${var.vm_count * var.environment_count}"
  pool  = "${var.openstack_networking_floatingip}"
}

# Create nodes
resource "openstack_compute_instance_v2" "vms" {
  count             = "${var.vm_count * var.environment_count}"
  name              = "${format("%s-kvm%02d.%02d.%s", var.prefix, count.index % var.vm_count + 1, count.index / var.vm_count + 1, var.domain)}"
  image_name        = "${count.index % var.vm_count == 0 ? var.openstack_compute_instance_kvm01_image_name : var.openstack_compute_instance_kvm_image_name}"
  flavor_name       = "${var.openstack_compute_instance_flavor_name}"
  availability_zone = "${var.openstack_availability_zone}"
  key_pair          = "${openstack_compute_keypair_v2.keypair.name}"
  security_groups   = ["${openstack_compute_secgroup_v2.secgroup.id}"]
  user_data         = "#cloud-config\nusers:\n  - name: ubuntu\n    ssh_authorized_keys:\n      - ${file(var.openstack_compute_keypair_public_key)}"

  network {
    uuid           = "${element(openstack_networking_network_v2.private-network.*.id, count.index)}"
    fixed_ip_v4    = "${cidrhost(var.openstack_networking_subnet_cidr, 10 + count.index % var.vm_count + 1)}"
    access_network = true
  }
}

# Associate floating IP with nodes
resource "openstack_compute_floatingip_associate_v2" "floatingip-associate" {
  count       = "${var.vm_count * var.environment_count}"
  floating_ip = "${element(openstack_networking_floatingip_v2.floatingip.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.vms.*.id, count.index)}"
}

output "vm_name" {
  value = "${openstack_compute_instance_v2.vms.*.name}"
}

output "vm_public_ip" {
  description = "The actual IP address allocated for the resource"
  value       = "${openstack_networking_floatingip_v2.floatingip.*.address}"
}

output "vm_private_ip" {
  description = "Private IPs for all VMs"
  value       = "${openstack_compute_instance_v2.vms.*.network.0.fixed_ip_v4}"
}
