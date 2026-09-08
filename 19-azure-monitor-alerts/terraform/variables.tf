variable "resource_group_name" { type = string; default = "monitoring-rg" }
variable "project_name" { type = string; default = "cloud-monitor" }
variable "alert_email" { type = string; description = "Email for alert notifications" }
variable "vm_resource_id" { type = string; description = "Resource ID of VM to monitor"; default = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Compute/virtualMachines/xxx" }
