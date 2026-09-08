output "function_app_url" { value = "https://${azurerm_linux_function_app.main.default_hostname}/api/orders" }
output "function_app_name" { value = azurerm_linux_function_app.main.name }
output "appinsights_instrumentation_key" { value = azurerm_application_insights.main.instrumentation_key; sensitive = true }
