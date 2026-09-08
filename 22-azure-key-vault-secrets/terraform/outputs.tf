output "key_vault_uri" { value = azurerm_key_vault.main.vault_uri }
output "key_vault_name" { value = azurerm_key_vault.main.name }
output "app_identity_client_id" { value = azurerm_user_assigned_identity.app.client_id }
