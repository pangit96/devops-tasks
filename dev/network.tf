locals {
	common_tags = {
		deployed_by = "terraform"
		environment = var.ENVIRONMENT
	}
}

# Create a resource group for network
resource "azurerm_resource_group" "network-rg" {
	name = "${var.AZ-LINUX-VM-NAME}-${var.ENVIRONMENT}-network"
	location = var.LOCATION
	tags = local.common_tags
}

# Create the network VNET
resource "azurerm_virtual_network" "network-vnet" {
	name = "${var.AZ-LINUX-VM-NAME}-${var.ENVIRONMENT}-vnet"
	address_space = [var.NETWORK-VNET-CIDR]
  	resource_group_name = azurerm_resource_group.network-rg.name
  	location = azurerm_resource_group.network-rg.location
	tags = local.common_tags
}

#Create a subnet for Network
resource "azurerm_subnet" "network-subnet" {
    depends_on=[data.azurerm_network_security_group.az-linux-vm-nsg]
    
	name = "${var.AZ-LINUX-VM-NAME}-${var.ENVIRONMENT}-subnet"
	address_prefix = var.NETWORK-SUBNET-CIDR
	virtual_network_name = azurerm_virtual_network.network-vnet.name
	resource_group_name  = azurerm_resource_group.network-rg.name
}
