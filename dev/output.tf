output "virtual_machine_name" {
    value = azurerm_virtual_machine.az-linux-vm.name
}

output "admin_username" {
    value = azurerm_virtual_machine.az-linux-vm.os_profile
}

output "admin_password" {
    value = random_password.AZ-LINUX-VM-PASSWORD.result
}

output "IP" {
    value = azurerm_public_ip.az-linux-vm-ip.ip_address
    
}

output "DNS" {
    value = azurerm_public_ip.az-linux-vm-ip.fqdn
}

