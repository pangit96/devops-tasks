terraform {
  	backend "azurerm" {
		resource_group_name = "terraform_remote_state"
		storage_account_name = "tfstorage2805"
		container_name = "tfcontainer2805"
		key = "terraform-ref-architecture-tfstate"
  	}
}
