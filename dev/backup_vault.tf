data "azurerm_backup_policy_vm" "az-vm-backup-policy" {
  name                = "DefaultPolicy"
  recovery_vault_name = var.AZ-VM-BACKUP-VAULT
  resource_group_name = var.AZ-VM-BACKUP-RG
}


