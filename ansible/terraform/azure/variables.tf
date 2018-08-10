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

variable "vm_nodes_cmp" {
  description = "Number of VMs which should be created as cmp hosts"
  default     = 3
}

variable "vm_nodes_osd" {
  description = "Number of VMs which should be created as osd hosts"
  default     = 3
}
