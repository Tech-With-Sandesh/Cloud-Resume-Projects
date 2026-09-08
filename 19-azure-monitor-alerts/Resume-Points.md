# Resume Points — Project 19: Azure Monitor Alerts

---

## Fresher

- Configured 3 types of Azure Monitor alerts using Terraform: Metric Alert (VM CPU >80%, 15-min window), Activity Log Alert (VM delete security event), and Log Search Alert (KQL query detecting >10 app errors in 5 minutes).
- Created an Action Group with email receiver using common alert schema — single Action Group wired to all alert rules for centralised notification routing.
- Used KQL (Kusto Query Language) in a scheduled query rule to filter AppTraces where SeverityLevel >= 3 and summarize error count per 5-minute bin.
- Configured alert severity levels (1=Error for app errors, 2=Warning for CPU) to enable tiered on-call routing in production PagerDuty or Ops integrations.

---

## Experienced Cloud Engineer

- Designed a multi-layer Azure Monitor observability system: Metric Alerts (VM CPU, 5-min frequency, 15-min window, PT5M/PT15M ISO 8601 durations) + Activity Log Alerts (VM delete — Administrative category, subscription scope) + Log Search Alerts v2 (KQL, AppTraces, error rate) — all routed to Action Group with common alert schema for consistent webhook payloads.
- Implemented Log Search Alert v2 with KQL: `AppTraces | where SeverityLevel >= 3 | summarize ErrorCount = count() by bin(TimeGenerated, 5m) | where ErrorCount > 10` — event-driven alerting from application telemetry without custom metric instrumentation.
- Configured Activity Log Alert at subscription scope monitoring `Microsoft.Compute/virtualMachines/delete` operation — detects VM deletion across all resource groups in the subscription, critical for accidental deletion forensics and security incident response.

---

## LinkedIn Project Description

Built a comprehensive Azure Monitor alerting system using Terraform — Metric Alert (VM CPU >80%, PT5M frequency, PT15M window), Activity Log Alert (VM delete, subscription scope), Log Search Alert v2 (KQL: AppTraces error rate >10/5min). Action Group with email (common alert schema). Alert severity tiering (Error vs Warning). Log Analytics Workspace (PerGB2018, 30-day retention).

---

## How to Explain in an Interview (30 Seconds)

"I set up three types of Azure Monitor alerts. The metric alert watches VM CPU — it evaluates every 5 minutes over a 15-minute window, so it only fires after sustained high CPU, not brief spikes. The activity log alert fires when any VM is deleted anywhere in the subscription — this is a security control so we immediately know if someone deletes infrastructure accidentally or maliciously. The log search alert runs a KQL query every 5 minutes against our Log Analytics Workspace counting application errors — if more than 10 errors occur in a 5-minute window, the operations team gets an email."

---

## Skills Demonstrated

- Azure Monitor Metric Alerts (frequency, window_size, severity, criteria)
- Activity Log Alerts (operation_name, category, subscription scope)
- Log Search Alerts v2 (KQL, evaluation_frequency, window_duration)
- KQL (Kusto Query Language — AppTraces, summarize, bin, where)
- Action Groups (email receiver, common alert schema)
- Alert severity levels (0-4 severity tiering)
- Log Analytics Workspace (PerGB2018, retention)
- ISO 8601 duration format (PT5M, PT15M for Azure Monitor)
- Azure Monitor Dashboard (Terraform azurerm_dashboard)
- Subscription-scoped activity log alerts (cross-resource-group monitoring)
