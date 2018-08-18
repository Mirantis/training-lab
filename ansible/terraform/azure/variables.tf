variable "environment_count" {
  default = 1
}

variable "azure_admin_username" {
  description = "Username which will be created on the VM"
  default     = "ubuntu"
}

variable "azure_dns_resource_group" {
  description = "Resource Group name handling the DNS (domain)"
}

variable "azure_images_resource_group" {
  description = "Resource Group containing the prebuild images"
  default     = "training-lab-images"
}

variable "azure_image_kvm01_name_regex" {
  description = "Regexp for the prebuild kvm01 image"
  default     = "training-lab-kvm01-ubuntu-16.04-server-amd64*"
}

variable "azure_image_kvm_name_regex" {
  description = "Regexp for the prebuild kvm image"
  default     = "training-lab-kvm-ubuntu-16.04-server-amd64*"
}

variable "azure_image_cmp_name_regex" {
  description = "Regexp for the prebuild cmp image"
  default     = "training-lab-kvm-ubuntu-16.04-server-amd64*"
}

variable "azure_image_osd_name_regex" {
  description = "Regexp for the prebuild osd image"
  default     = "training-lab-kvm-ubuntu-16.04-server-amd64*"
}

variable "azurerm_resource_group_location" {
  default = "East US"
}

variable "azurerm_subnet_address_prefix" {
  default = "192.168.250.0/24"
}

variable "azure_tags" {
  default = {
    Environment = "Training"
  }
}

variable "azurerm_virtual_machine_vm_size_kvm" {
  default = "Standard_D16_v3"
}

variable "azurerm_virtual_machine_vm_size_cmp" {
  default = "Standard_D16_v3"
}

variable "azurerm_virtual_machine_vm_size_osd" {
  default = "Standard_D16_v3"
}

variable "azurerm_virtual_network_address_space" {
  default = ["192.168.250.0/24"]
}

variable "domain" {
  default = "edu.example.com"
}

variable "prefix" {
  default = "terraform"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "vm_nodes_kvm" {
  description = "Number of VMs which should be created as kvm hosts"
  default     = 3
}

variable "vm_nodes_kvm_network_private_ip_last_octet" {
  description = "Last octet of kvm inside cloud_network (kvm01: 192.168.250.241, kvm02: 192.168.250.242, kvm03: 192.168.250.243 )"
  default     = 240
}

variable "vm_nodes_cmp" {
  description = "Number of VMs which should be created as cmp hosts"
  default     = 3
}

variable "vm_nodes_cmp_network_private_ip_last_octet" {
  description = "Last octet of kvm inside cloud_network (cmp01: 192.168.250.231, cmp02: 192.168.250.232, cmp03: 192.168.250.233 )"
  default     = 230
}

variable "vm_nodes_osd" {
  description = "Number of VMs which should be created as osd hosts"
  default     = 3
}

variable "vm_nodes_osd_network_private_ip_last_octet" {
  description = "Last octet of kvm inside cloud_network (osd01: 192.168.250.221, osd02: 192.168.250.222, osd03: 192.168.250.223 )"
  default     = 220
}
