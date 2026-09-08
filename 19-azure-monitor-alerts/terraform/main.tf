terraform {
  required_version = ">= 1.3.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.80" } }
}
provider "azurerm" { features {} }

data "azurerm_resource_group" "main" { name = var.resource_group_name }
data "azurerm_subscription" "current" {}

# ── Action Group (email + webhook) ──────────────────────────────────────────
resource "azurerm_monitor_action_group" "ops" {
  name                = "${var.project_name}-ops-ag"
  resource_group_name = data.azurerm_resource_group.main.name
  short_name          = "ops-alerts"

  email_receiver {
    name                    = "OpsTeam"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
}

# ── Log Analytics Workspace ──────────────────────────────────────────────────
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project_name}-logs"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ── Metric Alert — VM CPU High ─────────────────────────────────────────────
resource "azurerm_monitor_metric_alert" "vm_cpu" {
  name                = "${var.project_name}-vm-cpu-high"
  resource_group_name = data.azurerm_resource_group.main.name
  scopes              = [var.vm_resource_id]
  description         = "VM CPU utilization exceeds 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops.id
  }
}

# ── Activity Log Alert — VM Delete ──────────────────────────────────────────
resource "azurerm_monitor_activity_log_alert" "vm_delete" {
  name                = "${var.project_name}-vm-delete"
  resource_group_name = data.azurerm_resource_group.main.name
  scopes              = [data.azurerm_subscription.current.id]
  description         = "Alert when any VM is deleted"

  criteria {
    operation_name = "Microsoft.Compute/virtualMachines/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops.id
  }
}

# ── Log Search Alert — Application Errors ────────────────────────────────────
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "app_errors" {
  name                = "${var.project_name}-app-errors"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  scopes              = [azurerm_log_analytics_workspace.main.id]
  description         = "App error rate exceeds 10 per 5 minutes"
  severity            = 1
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"

  criteria {
    query                   = <<-QUERY
      AppTraces
      | where SeverityLevel >= 3
      | summarize ErrorCount = count() by bin(TimeGenerated, 5m)
      | where ErrorCount > 10
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"
  }

  action {
    action_groups = [azurerm_monitor_action_group.ops.id]
  }
}

# ── Azure Monitor Dashboard ──────────────────────────────────────────────────
resource "azurerm_dashboard" "main" {
  name                = "${var.project_name}-dashboard"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tags                = { hidden-title = "${var.project_name} Operations Dashboard" }

  dashboard_properties = jsonencode({
    lenses = {}
    metadata = {
      model = {
        timeRange = { value = { relative = { duration = 24, timeUnit = 1 } }, type = "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange" }
      }
    }
  })
}
