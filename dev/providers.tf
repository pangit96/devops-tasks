# Define terraform provider
terraform {
	required_version = ">=0.12"
}


# Define the Azure provider
provider "azurerm" {
	version = "=2.0.0"
	features {}
	subscription_id = var.AZ-SUBSCRIPTION-ID
}

