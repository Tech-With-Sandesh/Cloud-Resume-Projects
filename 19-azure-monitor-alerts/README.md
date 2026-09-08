# Project 19 - Azure Monitor: Metric Alerts, Activity Log Alerts, and Log Search Alerts

## Problem Statement

Your production Azure environment needs complete observability:
- Alert when VM CPU exceeds 80% for 15 minutes
- Alert immediately when any VM is deleted (security event)
- Alert when application error rate exceeds 10 errors per 5 minutes
- All alerts deliver to operations email via Action Group

Build a comprehensive Azure Monitor setup using Terraform.

---

## Architecture

```
Azure Resources (VM, App Service, etc.)
        │
        ├── Metric Alerts (VM CPU > 80%, 15-min window)
        ├── Activity Log Alert (VM delete — security event)
        └── Log Search Alert (App errors > 10/5min — KQL query)
                │
                ▼
        Action Group: ops-alerts
                │
                ▼
        Email: ops-team@company.com

Log Analytics Workspace ← Application logs (AppTraces)
```

---

## Project Structure

```
19-azure-monitor-alerts/
└── terraform/
    ├── main.tf    ← Action Group, 3 alert types, Log Analytics, Dashboard
    ├── variables.tf
    └── outputs.tf
```

---

## Step 1 — Deploy

```bash
export TF_VAR_alert_email="ops@yourcompany.com"
export TF_VAR_vm_resource_id="/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Compute/virtualMachines/your-vm"

# Create resource group first
az group create --name monitoring-rg --location eastus

cd terraform/
terraform init && terraform apply
```

---

## Step 2 — Confirm Email Subscription

Check your email — Azure sends a confirmation email for the Action Group email receiver. Click **Confirm** to activate alert emails.

---

## Step 3 — Test Metric Alert (force trigger)

```bash
# SSH into VM and run CPU stress test
sudo apt-get install -y stress
stress --cpu 4 --timeout 300 &
```

After 15 minutes at >80% CPU, you receive an email alert.

---

## Step 4 — Test Activity Log Alert

```bash
# Create and immediately delete a test VM
az vm create --name test-vm --resource-group monitoring-rg --image UbuntuLTS --generate-ssh-keys --size Standard_B1s
az vm delete --name test-vm --resource-group monitoring-rg --yes
```

You receive an email within 2 minutes of the deletion.

---

## Step 5 — Test Log Search Alert (KQL)

Send error-level log events to Log Analytics:

```bash
# Via Application Insights / Log Analytics data collector API or application code
# After 10+ error-severity events in 5 minutes, alert fires
```

---

## Verification Checklist

✅ Action Group created with email receiver

✅ VM CPU Metric Alert (severity 2, 15-min window, >80% threshold)

✅ VM Delete Activity Log Alert (Administrative category)

✅ Log Search Alert (KQL query on AppTraces — severity >= 3)

✅ Email confirmation received and confirmed for Action Group

✅ Test alerts trigger email notifications

---

## Troubleshooting

**No email received for alerts:**
- Confirm Action Group email via confirmation link
- Check Alert state: Azure Portal → Monitor → Alerts → Alert history

**Log Search Alert — `no data`:**
- Ensure application is sending telemetry to the Log Analytics Workspace
- Verify Workspace ID and key in application settings

---

## Cleanup

```bash
terraform destroy
az group delete --name monitoring-rg --yes
```

---

## Key Learnings

- Azure Monitor Metric Alerts (frequency, window_size, aggregation, threshold)
- Activity Log Alerts (operation_name, category — Administrative)
- Log Search Alerts v2 (KQL query, evaluation_frequency, window_duration)
- Action Groups (email receiver, common alert schema)
- Alert severity levels (0=Critical, 1=Error, 2=Warning, 3=Informational)
- KQL (Kusto Query Language) basics for log search alerts
- Log Analytics Workspace as centralized log store
- `evaluation_frequency` vs `window_duration` (how often to evaluate vs how much data to query)
- Azure Monitor Dashboard creation via Terraform
- Common alert schema (consistent JSON structure across all alert types)
