variable "environment_count" {
  default = 1
}

variable "openstack_auth_url" {
  description = "The endpoint url to connect to OpenStack"
}

variable "openstack_compute_instance_flavor_name" {}

variable "openstack_compute_instance_image_name" {
  default = "ubuntu-16-04-x64-201804032121"
}

variable "openstack_compute_keypair_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "openstack_networking_network_external_network_name" {
  default = "public"
}

variable "openstack_networking_subnet_cidr" {
  default = "192.168.250.0/24"
}

variable "openstack_networking_subnet_dns_nameservers" {
  default = ["8.8.8.8", "8.8.4.4"]
}

variable "openstack_networking_floatingip" {
  default = "public"
}

variable "openstack_password" {
  description = "The password for the Tenant"
}

variable "openstack_tenant_name" {
  description = "The name of the Tenant"
}

variable "openstack_user_name" {
  description = "The username for the Tenant"
}

variable "domain" {
  default = "edu.example.com"
}

variable "prefix" {
  default = "terraform"
}

variable "username" {
  description = "Username which will be used for connecting to VM"
  default     = "ubuntu"
}

variable "vm_count" {
  description = "Number of VMs which should be created"
  default     = 1
}
