output "aks_cluster_name" { value = azurerm_kubernetes_cluster.main.name }
output "acr_login_server" { value = azurerm_container_registry.main.login_server }
output "kubeconfig_command" { value = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${azurerm_kubernetes_cluster.main.name}" }
output "resource_group" { value = azurerm_resource_group.main.name }
