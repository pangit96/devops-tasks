provider "azurerm" {
  features {}
  subscription_id = var.AZ-SUBSCRIPTION-ID
}

terraform {
  required_providers {
    azurerm = {
      version = "2.39.0"
    }
  }
}
