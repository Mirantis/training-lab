# Configure the OpenStack Provider
provider "openstack" {
  auth_url    = "${var.openstack_auth_url}"
  password    = "${var.openstack_password}"
  tenant_name = "${var.openstack_tenant_name}"
  user_name   = "${var.openstack_user_name}"
}

data "openstack_networking_network_v2" "external_network" {
  name = "${var.openstack_networking_network_external_network_name}"
}

# Create Keypair
resource "openstack_compute_keypair_v2" "keypair" {
  name       = "${var.prefix}-keypair"
  public_key = "${file(var.openstack_compute_keypair_public_key)}"
}

# Create private network
resource "openstack_networking_network_v2" "private-network" {
  name           = "${var.prefix}-network"
  admin_state_up = "true"
}

# Create private subnet
resource "openstack_networking_subnet_v2" "private-subnet" {
  name            = "${var.prefix}-subnet"
  network_id      = "${openstack_networking_network_v2.private-network.id}"
  cidr            = "${var.openstack_networking_subnet_cidr}"
  dns_nameservers = "${var.openstack_networking_subnet_dns_nameservers}"
  enable_dhcp     = true
}

# Create router for private subnet
resource "openstack_networking_router_v2" "private-router" {
  name                = "${var.prefix}-router"
  external_network_id = "${data.openstack_networking_network_v2.external_network.id}"
  admin_state_up      = "true"
}

# Create router interface for private subnet
resource "openstack_networking_router_interface_v2" "router-interface" {
  router_id = "${openstack_networking_router_v2.private-router.id}"
  subnet_id = "${openstack_networking_subnet_v2.private-subnet.id}"
}

# Create floating IP for nodes
resource "openstack_networking_floatingip_v2" "floatingips" {
  count = "${var.vm_count * var.environment_count}"
  pool  = "${var.openstack_networking_floatingip}"
}

# Create nodes
resource "openstack_compute_instance_v2" "vms" {
  count       = "${var.vm_count * var.environment_count}"
  name        = "${format("%s-%02d-kvm%02d", var.prefix, count.index % var.environment_count + 1, count.index / var.environment_count + 1)}"
  image_name  = "${var.openstack_compute_instance_image_name}"
  flavor_name = "${var.openstack_compute_instance_flavor_name}"
  key_pair    = "${openstack_compute_keypair_v2.keypair.name}"
  user_data   = "#cloud-config\nusers:\n  - name: ubuntu\n    ssh_authorized_keys:\n      - ${file(var.openstack_compute_keypair_public_key)}"

  network {
    uuid           = "${openstack_networking_network_v2.private-network.id}"
    fixed_ip_v4    = "${cidrhost(var.openstack_networking_subnet_cidr, 10 * (count.index % var.environment_count + 1) + (count.index / var.environment_count + 1 ))}"
    access_network = true
  }
}

# Associate floating IP with nodes
resource "openstack_compute_floatingip_associate_v2" "floatingips-associate" {
  count       = "${var.vm_count * var.environment_count}"
  floating_ip = "${element(openstack_networking_floatingip_v2.floatingips.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.vms.*.id, count.index)}"
}

output "vm_name" {
  value = "${openstack_compute_instance_v2.vms.*.name}"
}

output "vm_public_ip" {
  description = "The actual IP address allocated for the resource"
  value       = "${openstack_networking_floatingip_v2.floatingips.*.address}"
}

output "vm_private_ip" {
  description = "Private IPs for all VMs"
  value       = "${openstack_compute_instance_v2.vms.*.network.0.fixed_ip_v4}"
}
