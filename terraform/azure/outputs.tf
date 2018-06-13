output "vm_passwords" {
    description = "User passwords for all VMs"
    value = "${zipmap(azurerm_virtual_machine.vm.*.name, random_string.password.*.result)}"
}

output "nic_private_ip" {
    description = "Private IPs for all VMs"
    value = "${zipmap(azurerm_virtual_machine.vm.*.name, azurerm_network_interface.nic.*.private_ip_address)}"
}

output "nic_public_ip" {
    description = "Public IPs for all VMs"
    value = "${zipmap(azurerm_virtual_machine.vm.*.name, azurerm_public_ip.pip.*.ip_address)}"
}
