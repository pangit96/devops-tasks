# Variables are declared in this file

variable "AZ-SUBSCRIPTION-ID"{}

variable "ENVIRONMENT"{
	type = string
	description = "environment tag"
	default = "dev"
}

variable "LOCATION"{
	type = string
	description = "Location of resource vm"
	default = "southeastasia"
}

variable "AZ-LINUX-VM-NAME"{
	type = string
	description = "Name of the virtual machine"
}

variable "AZ-LINUX-ADMIN-USER"{
	type = string
	description = "Admin Username"
}

variable "AZ-LINUX-VM-PASSWORD"{
	type = string
	description = "Admin user password"
    default = ""
}

variable "AZ-LINUX-VM-NSG"{
	type = string
	description = "Existing network security group for VM"
}

variable "AZ-VM-NSG-RG"{
	type = string
	description = "resource group of existing Network security group"
}

variable "AZ-LINUX-VM-SIZE"{
	type = string
	description = "VM instance size"
	default = "Standard_A4_v2"
}

variable "AZ-LINUX-LICENSE-TYPE" {
	type        = string
	description = "Specifies the BYOL type for the virtual machine."
	default     = null
}


variable "AZ-LINIX-VM-STORAGE-SKU"{
	type = string
	description = "VM storage sku"
	default = "StandardSSD_LRS"
}

variable "VM-OS-DISK-SIZE-GB"{
	description = "VM os disk size in GB"
	default = "50"
}

variable "NETWORK-VNET-CIDR" {
  	type        = string
  	description = "The CIDR of the network VNET"
}

variable "NETWORK-SUBNET-CIDR" {
	type        = string
  	description = "The CIDR for the network subnet"
}

variable "AZ-LINUX-VM-IMAGE" {
	type = map(string)
	description = "Virtual machine source image information"
	default = {
		publisher = "Canonical"
		offer = "UbuntuServer"
		sku = "18.04-LTS" 
		version = "latest"
	}
}

variable "AZ-VM-BACKUP-VAULT" {
    type = string
    description = "Virtual machine recovery vault name"
}

variable "AZ-VM-BACKUP-RG" {
    type = string
    description = "Virtual machine backup vault resource group"
}

variable "GIT-USER" {
    type = string
    description = "Github username"
}

variable "GIT-TOKEN" {
    type = string
    description = "Github Token"
}