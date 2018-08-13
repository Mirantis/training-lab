# Configure the Azure Provider
provider "azurerm" {}

# Check if custom (prebuild) Azure image exists
data "azurerm_image" "image_kvm01" {
  name_regex          = "${var.azure_image_kvm01_name_regex}"
  resource_group_name = "${var.azure_images_resource_group}"
  sort_descending     = true
}

data "azurerm_image" "image_kvm" {
  name_regex          = "${var.azure_image_kvm_name_regex}"
  resource_group_name = "${var.azure_images_resource_group}"
  sort_descending     = true
}

data "azurerm_image" "image_cmp" {
  name_regex          = "${var.azure_image_cmp_name_regex}"
  resource_group_name = "${var.azure_images_resource_group}"
  sort_descending     = true
}

data "azurerm_image" "image_osd" {
  name_regex          = "${var.azure_image_osd_name_regex}"
  resource_group_name = "${var.azure_images_resource_group}"
  sort_descending     = true
}

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

resource "azurerm_public_ip" "pip_kvm" {
  count                        = "${var.vm_nodes_kvm * var.environment_count}"
  name                         = "${format("%s-kvm%02d.%02d.%s-pip", var.prefix, count.index % var.vm_nodes_kvm + 1, count.index / var.vm_nodes_kvm + 1, var.domain)}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${replace(format("%s-kvm%02d.%02d.%s", var.prefix, count.index % var.vm_nodes_kvm + 1, count.index / var.vm_nodes_kvm + 1, var.domain), ".", "-")}"
  tags                         = "${var.azure_tags}"
}

resource "azurerm_public_ip" "pip_cmp" {
  count                        = "${var.vm_nodes_cmp * var.environment_count}"
  name                         = "${format("%s-cmp%02d.%02d.%s-pip", var.prefix, count.index % var.vm_nodes_cmp + 1, count.index / var.vm_nodes_cmp + 1, var.domain)}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${replace(format("%s-cmp%02d.%02d.%s", var.prefix, count.index % var.vm_nodes_cmp + 1, count.index / var.vm_nodes_cmp + 1, var.domain), ".", "-")}"
  tags                         = "${var.azure_tags}"
}

resource "azurerm_public_ip" "pip_osd" {
  count                        = "${var.vm_nodes_osd * var.environment_count}"
  name                         = "${format("%s-osd%02d.%02d.%s-pip", var.prefix, count.index % var.vm_nodes_osd + 1, count.index / var.vm_nodes_osd + 1, var.domain)}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${replace(format("%s-osd%02d.%02d.%s", var.prefix, count.index % var.vm_nodes_osd + 1, count.index / var.vm_nodes_osd + 1, var.domain), ".", "-")}"
  tags                         = "${var.azure_tags}"
}

resource "azurerm_network_interface" "nic_kvm" {
  count               = "${var.vm_nodes_kvm * var.environment_count}"
  name                = "${format("%s-kvm%02d.%02d.%s-nic", var.prefix, count.index % var.vm_nodes_kvm + 1, count.index / var.vm_nodes_kvm + 1, var.domain)}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  # enable_accelerated_networking = true
  tags = "${var.azure_tags}"

  ip_configuration {
    name                          = "${format("%s-kvm%02d.%02d.%s-ipconfig", var.prefix, count.index % var.vm_nodes_kvm + 1, count.index / var.vm_nodes_kvm + 1, var.domain)}"
    subnet_id                     = "${element(azurerm_subnet.subnet.*.id, count.index / var.vm_nodes_kvm)}"
    private_ip_address_allocation = "static"
    # 192.168.250.240
    private_ip_address            = "${cidrhost(var.azurerm_subnet_address_prefix, 240 + count.index % var.vm_nodes_kvm + 1 )}"
    public_ip_address_id          = "${element(azurerm_public_ip.pip_kvm.*.id, count.index)}"
  }
}

resource "azurerm_network_interface" "nic_cmp" {
  count               = "${var.vm_nodes_cmp * var.environment_count}"
  name                = "${format("%s-cmp%02d.%02d.%s-nic", var.prefix, count.index % var.vm_nodes_cmp + 1, count.index / var.vm_nodes_cmp + 1, var.domain)}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  # enable_accelerated_networking = true
  tags = "${var.azure_tags}"

  ip_configuration {
    name                          = "${format("%s-cmp%02d.%02d.%s-ipconfig", var.prefix, count.index % var.vm_nodes_cmp + 1, count.index / var.vm_nodes_cmp + 1, var.domain)}"
    subnet_id                     = "${element(azurerm_subnet.subnet.*.id, count.index / var.vm_nodes_cmp)}"
    private_ip_address_allocation = "static"
    # 192.168.250.230
    private_ip_address            = "${cidrhost(var.azurerm_subnet_address_prefix, 230 + count.index % var.vm_nodes_cmp + 1 )}"
    public_ip_address_id          = "${element(azurerm_public_ip.pip_cmp.*.id, count.index)}"
  }
}

resource "azurerm_network_interface" "nic_osd" {
  count               = "${var.vm_nodes_osd * var.environment_count}"
  name                = "${format("%s-osd%02d.%02d.%s-nic", var.prefix, count.index % var.vm_nodes_osd + 1, count.index / var.vm_nodes_osd + 1, var.domain)}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  # enable_accelerated_networking = true
  tags = "${var.azure_tags}"

  ip_configuration {
    name                          = "${format("%s-osd%02d.%02d.%s-ipconfig", var.prefix, count.index % var.vm_nodes_osd + 1, count.index / var.vm_nodes_osd + 1, var.domain)}"
    subnet_id                     = "${element(azurerm_subnet.subnet.*.id, count.index / var.vm_nodes_osd)}"
    private_ip_address_allocation = "static"
    # 192.168.250.220
    private_ip_address            = "${cidrhost(var.azurerm_subnet_address_prefix, 220 + count.index % var.vm_nodes_osd + 1 )}"
    public_ip_address_id          = "${element(azurerm_public_ip.pip_osd.*.id, count.index)}"
  }
}

resource "azurerm_dns_a_record" "dns-record_kvm" {
  count               = "${var.vm_nodes_kvm * var.environment_count}"
  name                = "${format("%s-kvm%02d.%02d", var.prefix, count.index % var.vm_nodes_kvm + 1, count.index / var.vm_nodes_kvm + 1)}"
  zone_name           = "${var.domain}"
  resource_group_name = "${var.azure_dns_resource_group}"
  ttl                 = 300
  records             = ["${element(azurerm_public_ip.pip_kvm.*.ip_address, count.index)}"]
  tags                = "${var.azure_tags}"
}

resource "azurerm_dns_a_record" "dns-record_cmp" {
  count               = "${var.vm_nodes_cmp * var.environment_count}"
  name                = "${format("%s-cmp%02d.%02d", var.prefix, count.index % var.vm_nodes_cmp + 1, count.index / var.vm_nodes_cmp + 1)}"
  zone_name           = "${var.domain}"
  resource_group_name = "${var.azure_dns_resource_group}"
  ttl                 = 300
  records             = ["${element(azurerm_public_ip.pip_cmp.*.ip_address, count.index)}"]
  tags                = "${var.azure_tags}"
}

resource "azurerm_dns_a_record" "dns-record_osd" {
  count               = "${var.vm_nodes_osd * var.environment_count}"
  name                = "${format("%s-osd%02d.%02d", var.prefix, count.index % var.vm_nodes_osd + 1, count.index / var.vm_nodes_osd + 1)}"
  zone_name           = "${var.domain}"
  resource_group_name = "${var.azure_dns_resource_group}"
  ttl                 = 300
  records             = ["${element(azurerm_public_ip.pip_osd.*.ip_address, count.index)}"]
  tags                = "${var.azure_tags}"
}

resource "azurerm_virtual_machine" "vms_kvm" {
  count                            = "${var.vm_nodes_kvm * var.environment_count}"
  name                             = "${format("%s-kvm%02d.%02d.%s", var.prefix, count.index % var.vm_nodes_kvm + 1, count.index / var.vm_nodes_kvm + 1, var.domain)}"
  location                         = "${azurerm_resource_group.rg.location}"
  resource_group_name              = "${azurerm_resource_group.rg.name}"
  vm_size                          = "${var.azurerm_virtual_machine_vm_size_kvm}"
  network_interface_ids            = ["${element(azurerm_network_interface.nic_kvm.*.id, count.index)}"]
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  tags                             = "${var.azure_tags}"

  storage_image_reference {
    id = "${count.index % var.vm_nodes_kvm == 0 ? data.azurerm_image.image_kvm01.id : data.azurerm_image.image_kvm.id}"

    #   publisher = "Canonical"
    #   offer     = "UbuntuServer"
    #   sku       = "16.04-LTS"
    #   version   = "latest"
  }

  storage_os_disk {
    name              = "${format("%s-kvm%02d.%02d.%s-osdisk", var.prefix, count.index % var.vm_nodes_kvm + 1, count.index / var.vm_nodes_kvm + 1, var.domain)}"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${format("%s-kvm%02d.%02d.%s", var.prefix, count.index % var.vm_nodes_kvm + 1, count.index / var.vm_nodes_kvm + 1, var.domain)}"
    admin_username = "${var.azure_admin_username}"
    admin_password = "not_used-${timestamp()}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_admin_username}/.ssh/authorized_keys"
      key_data = "${file(var.ssh_public_key)}"
    }
  }
}

resource "azurerm_virtual_machine" "vms_cmp" {
  count                            = "${var.vm_nodes_cmp * var.environment_count}"
  name                             = "${format("%s-cmp%02d.%02d.%s", var.prefix, count.index % var.vm_nodes_cmp + 1, count.index / var.vm_nodes_cmp + 1, var.domain)}"
  location                         = "${azurerm_resource_group.rg.location}"
  resource_group_name              = "${azurerm_resource_group.rg.name}"
  vm_size                          = "${var.azurerm_virtual_machine_vm_size_cmp}"
  network_interface_ids            = ["${element(azurerm_network_interface.nic_cmp.*.id, count.index)}"]
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  tags                             = "${var.azure_tags}"

  storage_image_reference {
    id = "${data.azurerm_image.image_cmp.id}"

    #   publisher = "Canonical"
    #   offer     = "UbuntuServer"
    #   sku       = "16.04-LTS"
    #   version   = "latest"
  }

  storage_os_disk {
    name              = "${format("%s-cmp%02d.%02d.%s-osdisk", var.prefix, count.index % var.vm_nodes_cmp + 1, count.index / var.vm_nodes_cmp + 1, var.domain)}"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${format("%s-cmp%02d.%02d.%s", var.prefix, count.index % var.vm_nodes_cmp + 1, count.index / var.vm_nodes_cmp + 1, var.domain)}"
    admin_username = "${var.azure_admin_username}"
    admin_password = "not_used-${timestamp()}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_admin_username}/.ssh/authorized_keys"
      key_data = "${file(var.ssh_public_key)}"
    }
  }
}

resource "azurerm_virtual_machine" "vms_osd" {
  count                            = "${var.vm_nodes_osd * var.environment_count}"
  name                             = "${format("%s-osd%02d.%02d.%s", var.prefix, count.index % var.vm_nodes_osd + 1, count.index / var.vm_nodes_osd + 1, var.domain)}"
  location                         = "${azurerm_resource_group.rg.location}"
  resource_group_name              = "${azurerm_resource_group.rg.name}"
  vm_size                          = "${var.azurerm_virtual_machine_vm_size_osd}"
  network_interface_ids            = ["${element(azurerm_network_interface.nic_osd.*.id, count.index)}"]
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  tags                             = "${var.azure_tags}"

  storage_image_reference {
    id = "${data.azurerm_image.image_osd.id}"

    #   publisher = "Canonical"
    #   offer     = "UbuntuServer"
    #   sku       = "16.04-LTS"
    #   version   = "latest"
  }

  storage_os_disk {
    name              = "${format("%s-osd%02d.%02d.%s-osdisk", var.prefix, count.index % var.vm_nodes_osd + 1, count.index / var.vm_nodes_osd + 1, var.domain)}"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${format("%s-osd%02d.%02d.%s", var.prefix, count.index % var.vm_nodes_osd + 1, count.index / var.vm_nodes_osd + 1, var.domain)}"
    admin_username = "${var.azure_admin_username}"
    admin_password = "not_used-${timestamp()}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_admin_username}/.ssh/authorized_keys"
      key_data = "${file(var.ssh_public_key)}"
    }
  }
}

output "vms_kvm_azure_fqdn" {
  description = "Azure Internal FQDNs for kvm VMs"
  value       = "${azurerm_public_ip.pip_kvm.*.fqdn}"
}

output "vms_cmp_azure_fqdn" {
  description = "Azure Internal FQDNs for cmp VMs"
  value       = "${azurerm_public_ip.pip_cmp.*.fqdn}"
}

output "vms_osd_azure_fqdn" {
  description = "Azure Internal FQDNs for osd VMs"
  value       = "${azurerm_public_ip.pip_osd.*.fqdn}"
}

output "vms_kvm_name" {
  description = "FQDNs for kvm VMs"
  value       = "${azurerm_virtual_machine.vms_kvm.*.name}"
}

output "vms_cmp_name" {
  description = "FQDNs for cmp VMs"
  value       = "${azurerm_virtual_machine.vms_cmp.*.name}"
}

output "vms_osd_name" {
  description = "FQDNs for osd VMs"
  value       = "${azurerm_virtual_machine.vms_osd.*.name}"
}

output "vms_kvm_private_ip_address" {
  description = "Private IPs for kvm VMs"
  value       = "${azurerm_network_interface.nic_kvm.*.private_ip_address}"
}

output "vms_cmp_private_ip_address" {
  description = "Private IPs for cmp VMs"
  value       = "${azurerm_network_interface.nic_cmp.*.private_ip_address}"
}

output "vms_osd_private_ip_address" {
  description = "Private IPs for osd VMs"
  value       = "${azurerm_network_interface.nic_osd.*.private_ip_address}"
}

output "vms_kvm_public_ip" {
  description = "Public IPs for kvm VMs"
  value       = "${azurerm_public_ip.pip_kvm.*.ip_address}"
}

output "vms_cmp_public_ip" {
  description = "Public IPs for cmp VMs"
  value       = "${azurerm_public_ip.pip_cmp.*.ip_address}"
}

output "vms_osd_public_ip" {
  description = "Public IPs for osd VMs"
  value       = "${azurerm_public_ip.pip_osd.*.ip_address}"
}
