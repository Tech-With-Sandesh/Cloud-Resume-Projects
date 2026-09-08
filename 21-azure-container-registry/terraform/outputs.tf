output "acr_login_server" { value = azurerm_container_registry.main.login_server }
output "aci_fqdn" { value = azurerm_container_group.main.fqdn }
output "aci_ip" { value = azurerm_container_group.main.ip_address }
