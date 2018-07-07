# Configure the Azure Provider
provider "azurerm" {}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = "${var.azurerm_resource_group_location}"
  tags     = "${var.azure_tags}"
}

resource "azurerm_virtual_network" "vnet" {
  count               = "${var.environment_count}"
  name                = "${format("%s-%02d-vnet", var.prefix, count.index + 1)}"
  address_space       = "${var.azurerm_virtual_network_address_space}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tags                = "${var.azure_tags}"
}

resource "azurerm_subnet" "subnet" {
  count                = "${var.environment_count}"
  name                 = "${format("%s-%02d-subnet", var.prefix, count.index + 1)}"
  virtual_network_name = "${element(azurerm_virtual_network.vnet.*.name, count.index)}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.azurerm_subnet_address_prefix}"
}

resource "azurerm_public_ip" "pip" {
  count                        = "${var.vm_count * var.environment_count}"
  name                         = "${format("%s-kvm%02d.%02d.%s-pip", var.prefix, count.index / var.environment_count + 1, count.index % var.environment_count + 1, var.domain)}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${replace(format("%s-kvm%02d-%02d-%s", var.prefix, count.index / var.environment_count + 1, count.index % var.environment_count + 1, var.domain), ".", "-")}"
  tags                         = "${var.azure_tags}"
}

resource "azurerm_network_interface" "nic" {
  count               = "${var.vm_count * var.environment_count}"
  name                = "${format("%s-kvm%02d.%02d.%s-nic", var.prefix, count.index / var.environment_count + 1, count.index % var.environment_count + 1, var.domain)}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  # enable_accelerated_networking = true
  tags = "${var.azure_tags}"

  ip_configuration {
    name                          = "${format("%s-kvm%02d.%02d.%s-ipconfig", var.prefix, count.index / var.environment_count + 1, count.index % var.environment_count + 1, var.domain)}"
    subnet_id                     = "${element(azurerm_subnet.subnet.*.id, count.index % var.environment_count)}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${cidrhost(var.azurerm_subnet_address_prefix, 10 + count.index / var.environment_count + 1 )}"
    public_ip_address_id          = "${element(azurerm_public_ip.pip.*.id, count.index)}"
  }
}

resource "azurerm_dns_a_record" "dns-record" {
  count               = "${var.vm_count * var.environment_count}"
  name                = "${format("%s-kvm%02d.%02d", var.prefix, count.index / var.environment_count + 1, count.index % var.environment_count + 1)}"
  zone_name           = "${var.domain}"
  resource_group_name = "${var.azure_dns_resource_group}"
  ttl                 = 300
  records             = ["${element(azurerm_public_ip.pip.*.ip_address, count.index)}"]
  tags                = "${var.azure_tags}"
}

resource "azurerm_virtual_machine" "vm" {
  count                            = "${var.vm_count * var.environment_count}"
  name                             = "${format("%s-kvm%02d.%02d.%s", var.prefix, count.index / var.environment_count + 1, count.index % var.environment_count + 1, var.domain)}"
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
    name              = "${format("%s-kvm%02d.%02d.%s-osdisk", var.prefix, count.index / var.environment_count + 1, count.index % var.environment_count + 1, var.domain)}"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${format("%s-kvm%02d.%02d.%s", var.prefix, count.index / var.environment_count + 1, count.index % var.environment_count + 1, var.domain)}"
    admin_username = "${var.azure_admin_username}"
    admin_password = "${var.azure_admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_admin_username}/.ssh/authorized_keys"
      key_data = "${file(var.ssh_public_key)}"
    }
  }
}

output "vm_azure_fqdn" {
  description = "Azure Internal FQDNs for all VMs"
  value       = "${azurerm_public_ip.pip.*.fqdn}"
}

output "vm_name" {
  description = "FQDNs for all VMs"
  value       = "${azurerm_virtual_machine.vm.*.name}"
}

output "vm_private_ip_address" {
  description = "Private IPs for all VMs"
  value       = "${azurerm_network_interface.nic.*.private_ip_address}"
}

output "vm_public_ip" {
  description = "Public IPs for all VMs"
  value       = "${azurerm_public_ip.pip.*.ip_address}"
}
