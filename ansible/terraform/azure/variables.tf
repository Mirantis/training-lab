variable "environment_count" {
  default = 1
}

variable "azure_admin_username" {
  description = "Username which will be created on the VM"
  default     = "ubuntu"
}

variable "azure_admin_password" {
  description = "Password for \"admin\" username"
}

variable "azure_dns_resource_group" {
  default = "training-lab-dns"
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

variable "azurerm_virtual_machine_vm_size" {
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

variable "vm_count" {
  description = "Number of VMs which should be created"
  default     = 3
}
