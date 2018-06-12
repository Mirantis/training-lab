# Configure the OpenStack Provider
provider "openstack" {
  auth_url    = "${var.openstack_auth_url}"
  password    = "${var.openstack_password}"
  tenant_name = "${var.openstack_tenant_name}"
  user_name   = "${var.openstack_user_name}"
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "${var.openstack_compute_keypair_name}"
  public_key = "${file(var.openstack_compute_keypair_public_key)}"
}
