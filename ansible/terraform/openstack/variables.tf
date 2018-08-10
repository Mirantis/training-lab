variable "environment_count" {
  default = 1
}

variable "openstack_auth_url" {
  description = "The endpoint url to connect to OpenStack"
}

variable "openstack_availability_zone" {
  description = "The availability zone in which to create the server"
  default = "nova"
}

variable "openstack_compute_instance_flavor_name_kvm" {
  description = "Name of kvm flavor in OpenStack"
  default = "m1.xlarge"
}

variable "openstack_compute_instance_flavor_name_cmp" {
  description = "Name of cmp flavor in OpenStack"
  default = "m1.xlarge"
}

variable "openstack_compute_instance_flavor_name_osd" {
  description = "Name of osd flavor in OpenStack"
  default = "m1.xlarge"
}

variable "openstack_compute_instance_kvm01_image_name" {
  description = "Image name for kvm01 VMs in OpenStack"
  default = "training-lab_kvm01-ubuntu-16.04-server-amd64-20180803"
}

variable "openstack_compute_instance_kvm_image_name" {
  description = "Image name for kvm VMs in OpenStack"
  default = "training-lab_kvm-ubuntu-16.04-server-amd64-20180803"
}

variable "openstack_compute_instance_cmp_image_name" {
  description = "Image name for cmp VMs in OpenStack"
  default = "training-lab_kvm-ubuntu-16.04-server-amd64-20180803"
}

variable "openstack_compute_instance_osd_image_name" {
  description = "Image name for osd VMs in OpenStack"
  default = "training-lab_kvm-ubuntu-16.04-server-amd64-20180803"
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
  description = "Prefix used for all names"
  default     = "terraform"
}

variable "username" {
  description = "Username which will be used for connecting to VM"
  default     = "ubuntu"
}

variable "vm_nodes_kvm" {
  description = "Number of VMs which should be created as kvm hosts"
  default     = 3
}

variable "vm_nodes_cmp" {
  description = "Number of VMs which should be created as cmp hosts"
  default     = 3
}

variable "vm_nodes_osd" {
  description = "Number of VMs which should be created as osd hosts"
  default     = 3
}
