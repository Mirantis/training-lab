# Configure the Azure Provider
provider "azurerm" {}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = "${var.azurerm_resource_group_location}"
  tags     = "${var.azure_tags}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = "${var.azurerm_virtual_network_address_space}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tags                = "${var.azure_tags}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.azurerm_subnet_address_prefix}"
}

resource "azurerm_public_ip" "pip" {
  count                        = "${var.vm_count * var.environment_count}"
  name                         = "${format("%s-%02d-kvm%02d-pip", var.prefix, count.index % var.environment_count + 1, count.index / var.environment_count + 1)}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${format("%s-%02d-kvm%02d", var.prefix, count.index % var.environment_count + 1, count.index / var.environment_count + 1)}"
  tags                         = "${var.azure_tags}"
}

resource "azurerm_network_interface" "nic" {
  count               = "${var.vm_count * var.environment_count}"
  name                = "${format("%s-%02d-kvm%02d-nic", var.prefix, count.index % var.environment_count + 1, count.index / var.environment_count + 1)}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tags                = "${var.azure_tags}"

  ip_configuration {
    name                          = "${var.prefix}-ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${cidrhost(var.azurerm_subnet_address_prefix, 10 * (count.index % var.environment_count + 1) + (count.index / var.environment_count + 1 ))}"
    public_ip_address_id          = "${element(azurerm_public_ip.pip.*.id, count.index)}"
  }
}

resource "random_string" "password" {
  count       = "${var.vm_count * var.environment_count}"
  length      = 6
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  special     = false
}

resource "azurerm_virtual_machine" "vm" {
  count                            = "${var.vm_count * var.environment_count}"
  name                             = "${format("%s-%02d-kvm%02d-vm", var.prefix, count.index % var.environment_count + 1, count.index / var.environment_count + 1)}"
  location                         = "${azurerm_resource_group.rg.location}"
  resource_group_name              = "${azurerm_resource_group.rg.name}"
  vm_size                          = "${var.azurerm_virtual_machine_vm_size}"
  network_interface_ids            = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  tags                             = "${var.azure_tags}"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${format("%s-%02d-kvm%02d-osdisk", var.prefix, count.index % var.environment_count + 1, count.index / var.environment_count + 1)}"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${format("%s-%02d-kvm%02d", var.prefix, count.index % var.environment_count + 1, count.index / var.environment_count + 1)}"
    admin_username = "${var.azure_admin_username}"
    admin_password = "${var.azure_admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.username}/.ssh/authorized_keys"
      key_data = "${file(var.ssh_public_key)}"
    }
  }
}

output "vm_name" {
  value = "${azurerm_virtual_machine.vm.*.name}"
}

output "vm_private_ip" {
  description = "Private IPs for all VMs"
  value       = "${azurerm_network_interface.nic.*.private_ip_address}"
}

output "vm_public_ip" {
  description = "Public IPs for all VMs"
  value       = "${azurerm_public_ip.pip.*.ip_address}"
}
