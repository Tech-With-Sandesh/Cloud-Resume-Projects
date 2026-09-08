# Resume Points — Project 10: AWS CloudWatch Monitoring

---

## Fresher

- Built a complete AWS observability stack using Terraform: CloudWatch Dashboard (4 metric widgets), 6 CloudWatch Alarms (EC2 CPU/status, RDS CPU/storage, app errors), SNS email alerts, and a custom log metric filter for application error rate monitoring.
- Configured CloudWatch Log Metric Filter with `ERROR` pattern to extract a custom metric (ErrorCount) from application logs and trigger an alarm when error rate exceeds 10 per minute.
- Set `treat_missing_data = "notBreaching"` on log-based alarms to prevent false alerts during periods of no application traffic.
- Added `ok_actions` alongside `alarm_actions` for recovery notifications — alerting the team when a threshold returns to normal, not only when it breaches.

---

## Experienced Cloud Engineer

- Designed a multi-layer observability system: infrastructure metrics (EC2 CPU/NetworkIO, RDS CPU/storage/connections) + application log metrics (error rate via metric filter) + CloudWatch Dashboard — all configured as Terraform code with SNS email delivery.
- Implemented CloudWatch Log Metric Filter extracting custom metric from application logs: `pattern = "ERROR"` increments `ErrorCount` custom metric in application namespace, with alarm triggering at >10 errors/minute — enabling proactive alerting without log querying.
- Configured CloudWatch alarm evaluation strategy: 2 evaluation_periods × 5-minute period = alarm fires after 10 consecutive minutes of >80% CPU (EC2); RDS storage alarm fires immediately on single breach — different evaluation sensitivity per metric criticality.
- Documented Amazon CloudWatch Synthetics (canary monitoring), Container Insights (ECS/EKS), and X-Ray distributed tracing as production observability extensions.

---

## LinkedIn Project Description

Built a complete AWS observability platform using Terraform — CloudWatch Dashboard (EC2 CPU/Network, RDS CPU/Connections), 6 metric alarms (EC2 CPU >80%, StatusCheck, RDS CPU >75%, FreeStorage <5GB, App Errors >10/min), SNS email alerts with ok_actions for recovery notifications. CloudWatch Log Metric Filter extracting ErrorCount from application logs. treat_missing_data=notBreaching to prevent false alarms.

---

## GitHub Project Description

AWS CloudWatch Monitoring (Terraform) — Dashboard (4 widgets), 6 alarms (EC2 + RDS + log-based), SNS email, Log Metric Filter (ERROR → custom metric), treat_missing_data=notBreaching, ok_actions. Full observability stack as code.

---

## How to Explain in an Interview (30 Seconds)

"I built a CloudWatch observability setup entirely in Terraform. The interesting part is the application error monitoring — I created a CloudWatch Log Metric Filter on the application log group that counts lines containing the word ERROR. This creates a custom metric in CloudWatch, and I have an alarm that fires if that count exceeds 10 per minute. So if the application starts throwing errors, within a minute, the on-call engineer gets an email. I also set treat_missing_data to notBreaching so we don't get false alarms during off-hours when there's no traffic and no logs."

---

## Skills Demonstrated

- Amazon CloudWatch (metrics, alarms, dashboards, log groups)
- CloudWatch Metric Alarms (evaluation_periods, threshold, comparison operators)
- CloudWatch Log Metric Filter (pattern matching, custom namespace)
- treat_missing_data (alarm behaviour when no data points exist)
- ok_actions (recovery notifications, not just breach notifications)
- Amazon SNS (topic, email subscription, confirmation)
- CloudWatch Dashboard as code (widget grid, metric definitions)
- EC2 Metrics (CPU, NetworkIn/Out, StatusCheckFailed)
- RDS Metrics (CPU, FreeStorageSpace, DatabaseConnections)
- Custom application metrics via log pattern extraction
- Alarm testing with `set-alarm-state`
