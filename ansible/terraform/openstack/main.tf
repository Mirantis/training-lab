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
  count      = "${var.environment_count}"
  router_id  = "${element(openstack_networking_router_v2.private-router.*.id, count.index)}"
  subnet_id  = "${element(openstack_networking_subnet_v2.private-subnet.*.id, count.index)}"
}

# Create floating IP for kvm nodes
resource "openstack_networking_floatingip_v2" "floatingip_kvm" {
  count = "${var.vm_nodes_kvm * var.environment_count}"
  pool  = "${var.openstack_networking_floatingip}"
}

# Create floating IP for cmp nodes
resource "openstack_networking_floatingip_v2" "floatingip_cmp" {
  count = "${var.vm_nodes_cmp * var.environment_count}"
  pool  = "${var.openstack_networking_floatingip}"
}

# Create floating IP for osd nodes
resource "openstack_networking_floatingip_v2" "floatingip_osd" {
  count = "${var.vm_nodes_osd * var.environment_count}"
  pool  = "${var.openstack_networking_floatingip}"
}

# Create kvm nodes
resource "openstack_compute_instance_v2" "vms_kvm" {
  count             = "${var.vm_nodes_kvm * var.environment_count}"
  name              = "${format("%s-kvm%02d.%02d.%s", var.prefix, count.index % var.vm_nodes_kvm + 1, count.index / var.vm_nodes_kvm + 1, var.domain)}"
  image_name        = "${count.index % var.vm_nodes_kvm == 0 ? var.openstack_compute_instance_kvm01_image_name : var.openstack_compute_instance_kvm_image_name}"
  flavor_name       = "${var.openstack_compute_instance_flavor_name_kvm}"
  availability_zone = "${var.openstack_availability_zone}"
  key_pair          = "${openstack_compute_keypair_v2.keypair.name}"
  security_groups   = ["${openstack_compute_secgroup_v2.secgroup.name}"]
  user_data         = "#cloud-config\nusers:\n  - name: ubuntu\n    ssh_authorized_keys:\n      - ${file(var.openstack_compute_keypair_public_key)}"
  depends_on        = ["openstack_networking_router_interface_v2.router-interface"]

  network {
    uuid           = "${element(openstack_networking_network_v2.private-network.*.id, count.index / var.vm_nodes_kvm )}"
    fixed_ip_v4    = "${cidrhost(var.openstack_networking_subnet_cidr, var.vm_nodes_kvm_network_private_ip_last_octet + count.index % var.vm_nodes_kvm + 1)}"
    access_network = true
  }
}

# Create cmp nodes
resource "openstack_compute_instance_v2" "vms_cmp" {
  count             = "${var.vm_nodes_cmp * var.environment_count}"
  name              = "${format("%s-cmp%02d.%02d.%s", var.prefix, count.index % var.vm_nodes_cmp + 1, count.index / var.vm_nodes_cmp + 1, var.domain)}"
  image_name        = "${var.openstack_compute_instance_cmp_image_name}"
  flavor_name       = "${var.openstack_compute_instance_flavor_name_cmp}"
  availability_zone = "${var.openstack_availability_zone}"
  key_pair          = "${openstack_compute_keypair_v2.keypair.name}"
  security_groups   = ["${openstack_compute_secgroup_v2.secgroup.name}"]
  user_data         = "#cloud-config\nusers:\n  - name: ubuntu\n    ssh_authorized_keys:\n      - ${file(var.openstack_compute_keypair_public_key)}"
  depends_on        = ["openstack_networking_router_interface_v2.router-interface"]

  network {
    uuid           = "${element(openstack_networking_network_v2.private-network.*.id, count.index / var.vm_nodes_cmp )}"
    fixed_ip_v4    = "${cidrhost(var.openstack_networking_subnet_cidr, var.vm_nodes_cmp_network_private_ip_last_octet + count.index % var.vm_nodes_cmp + 1)}"
    access_network = true
  }
}

# Create osd nodes
resource "openstack_compute_instance_v2" "vms_osd" {
  count             = "${var.vm_nodes_osd * var.environment_count}"
  name              = "${format("%s-osd%02d.%02d.%s", var.prefix, count.index % var.vm_nodes_osd + 1, count.index / var.vm_nodes_osd + 1, var.domain)}"
  image_name        = "${var.openstack_compute_instance_osd_image_name}"
  flavor_name       = "${var.openstack_compute_instance_flavor_name_osd}"
  availability_zone = "${var.openstack_availability_zone}"
  key_pair          = "${openstack_compute_keypair_v2.keypair.name}"
  security_groups   = ["${openstack_compute_secgroup_v2.secgroup.name}"]
  user_data         = "#cloud-config\nusers:\n  - name: ubuntu\n    ssh_authorized_keys:\n      - ${file(var.openstack_compute_keypair_public_key)}"
  depends_on        = ["openstack_networking_router_interface_v2.router-interface"]

  network {
    uuid           = "${element(openstack_networking_network_v2.private-network.*.id, count.index / var.vm_nodes_osd )}"
    fixed_ip_v4    = "${cidrhost(var.openstack_networking_subnet_cidr, var.vm_nodes_osd_network_private_ip_last_octet + count.index % var.vm_nodes_osd + 1)}"
    access_network = true
  }
}

# Associate floating IP with kvm nodes
resource "openstack_compute_floatingip_associate_v2" "floatingip-associate_kvm" {
  count       = "${var.vm_nodes_kvm * var.environment_count}"
  floating_ip = "${element(openstack_networking_floatingip_v2.floatingip_kvm.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.vms_kvm.*.id, count.index)}"
}

# Associate floating IP with cmp nodes
resource "openstack_compute_floatingip_associate_v2" "floatingip-associate_cmp" {
  count       = "${var.vm_nodes_cmp * var.environment_count}"
  floating_ip = "${element(openstack_networking_floatingip_v2.floatingip_cmp.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.vms_cmp.*.id, count.index)}"
}

# Associate floating IP with osd nodes
resource "openstack_compute_floatingip_associate_v2" "floatingip-associate_osd" {
  count       = "${var.vm_nodes_osd * var.environment_count}"
  floating_ip = "${element(openstack_networking_floatingip_v2.floatingip_osd.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.vms_osd.*.id, count.index)}"
}

output "vms_name" {
  value = "${concat(openstack_compute_instance_v2.vms_kvm.*.name, openstack_compute_instance_v2.vms_cmp.*.name, openstack_compute_instance_v2.vms_osd.*.name)}"
}

output "vms_public_ip" {
  description = "The public IP address for VMs"
  value       = "${concat(openstack_networking_floatingip_v2.floatingip_kvm.*.address, openstack_networking_floatingip_v2.floatingip_cmp.*.address, openstack_networking_floatingip_v2.floatingip_osd.*.address)}"
}