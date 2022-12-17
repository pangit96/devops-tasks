
locals {
	tags_common = {
		deployed_by = "terraform"
		environment = var.ENVIRONMENT
	}
}

# Generate random password
resource "random_password" "AZ-LINUX-VM-PASSWORD" {
	length = 16
	min_upper = 2
	min_lower = 2
	min_special = 2
	number = true
	special = true
	override_special = "!@#$%&"
}

# Select existing NSG 
data "azurerm_network_security_group" "az-linux-vm-nsg" {
    depends_on=[azurerm_resource_group.network-rg]
    
  	name = var.AZ-LINUX-VM-NSG
	resource_group_name = var.AZ-VM-NSG-RG
}

# Associate the web NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "az-linux-vm-nsg-association" {
    depends_on=[data.azurerm_network_security_group.az-linux-vm-nsg, azurerm_subnet.network-subnet]
    
	subnet_id = azurerm_subnet.network-subnet.id
	network_security_group_id = data.azurerm_network_security_group.az-linux-vm-nsg.id
}

# Get a Static Public IP
resource "azurerm_public_ip" "az-linux-vm-ip" {
	depends_on=[azurerm_resource_group.network-rg]

	name = "${var.AZ-LINUX-VM-NAME}-vm-ip"
	location = var.LOCATION
	resource_group_name = azurerm_resource_group.network-rg.name
	allocation_method = "Static"
	domain_name_label = "${var.AZ-LINUX-VM-NAME}monsoon"
	tags = local.tags_common
}


# Create Network Interface Card
resource "azurerm_network_interface" "az-linux-vm-nic" {
	depends_on=[azurerm_public_ip.az-linux-vm-ip]
	
	name = "${var.AZ-LINUX-VM-NAME}-vm-nic"
	location = azurerm_resource_group.network-rg.location
	resource_group_name = azurerm_resource_group.network-rg.name
    
	ip_configuration {
   		name  = "internal"
        subnet_id = azurerm_subnet.network-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.az-linux-vm-ip.id
  	}

	tags = local.tags_common
}

resource "azurerm_network_interface_security_group_association" "az-nsg-association" {
    depends_on=[azurerm_network_interface.az-linux-vm-nic, data.azurerm_network_security_group.az-linux-vm-nsg]
    
    network_interface_id      = azurerm_network_interface.az-linux-vm-nic.id
    network_security_group_id = data.azurerm_network_security_group.az-linux-vm-nsg.id
}


locals {
  custom_data = <<CUSTOM_DATA
#!/bin/bash
usermod -aG sudo ${var.AZ-LINUX-ADMIN-USER}
echo '${var.AZ-LINUX-ADMIN-USER} ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

sudo -u ${var.AZ-LINUX-ADMIN-USER} mkdir /home/${var.AZ-LINUX-ADMIN-USER}/repo

sudo -u ${var.AZ-LINUX-ADMIN-USER} git clone https://${var.GIT-USER}:${var.GIT-TOKEN}@github.com/monsoon-fintech/monsoon-infrastructure.git /home/${var.AZ-LINUX-ADMIN-USER}/repo/monsoon-infrastructure

sudo -u ${var.AZ-LINUX-ADMIN-USER} git clone -b devops https://${var.GIT-USER}:${var.GIT-TOKEN}@github.com/monsoon-fintech/ml_implementation.git /home/${var.AZ-LINUX-ADMIN-USER}/repo/ml_implementation

sudo -u ${var.AZ-LINUX-ADMIN-USER} git clone https://${var.GIT-USER}:${var.GIT-TOKEN}@github.com/monsoon-fintech/processing_raw_data.git /home/${var.AZ-LINUX-ADMIN-USER}/repo/processing_raw_data

CUSTOM_DATA
}


# Create Linux VM
resource "azurerm_virtual_machine" "az-linux-vm" {
	depends_on=[azurerm_network_interface.az-linux-vm-nic]

	location              = azurerm_resource_group.network-rg.location
	resource_group_name   = azurerm_resource_group.network-rg.name
	name                  = var.AZ-LINUX-VM-NAME
	network_interface_ids = [azurerm_network_interface.az-linux-vm-nic.id]
	vm_size               = var.AZ-LINUX-VM-SIZE
	license_type          = var.AZ-LINUX-LICENSE-TYPE

	delete_os_disk_on_termination    = false
	delete_data_disks_on_termination = false

	storage_image_reference {
		id        = lookup(var.AZ-LINUX-VM-IMAGE, "id", null)
		offer     = lookup(var.AZ-LINUX-VM-IMAGE, "offer", null)
		publisher = lookup(var.AZ-LINUX-VM-IMAGE, "publisher", null)
		sku       = lookup(var.AZ-LINUX-VM-IMAGE, "sku", null)
		version   = lookup(var.AZ-LINUX-VM-IMAGE, "version", null)
	}

	storage_os_disk {
		name = "${var.AZ-LINUX-VM-NAME}-os-disk"
		caching = "ReadWrite"
		create_option = "FromImage"
        disk_size_gb = var.VM-OS-DISK-SIZE-GB
		managed_disk_type = var.AZ-LINIX-VM-STORAGE-SKU
	}

	os_profile {
		computer_name  = "${var.AZ-LINUX-VM-NAME}-monsoon"
		admin_username = var.AZ-LINUX-ADMIN-USER
		admin_password = random_password.AZ-LINUX-VM-PASSWORD.result
        custom_data = base64encode(local.custom_data)
	}

	os_profile_linux_config {
	disable_password_authentication = false
	}


	tags = local.tags_common
    
    provisioner "remote-exec" {
      connection {
        type     = "ssh"
        user     = var.AZ-LINUX-ADMIN-USER
        password = random_password.AZ-LINUX-VM-PASSWORD.result
        host     = azurerm_public_ip.az-linux-vm-ip.fqdn
      }
      
      inline = [
      "echo Running vm_configure script in a tmux session",
      "tmux new-session -d -s vm_configure bash && tmux set-option -t vm_configure remain-on-exit on && tmux  send-keys -t vm_configure.0 'export SHELL=/bin/bash; /bin/bash /home/${var.AZ-LINUX-ADMIN-USER}/repo/monsoon-infrastructure/vm_configure/vm_cofigure_python-3.6.sh' ENTER"
      ]
      on_failure = continue
    }

}


