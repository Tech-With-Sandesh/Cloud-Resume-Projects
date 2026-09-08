# Project 10 - AWS CloudWatch Monitoring: Dashboards, Alarms, Log Metric Filters and SNS Alerts

## Problem Statement

Your production infrastructure needs full observability:
- Real-time dashboard for EC2 and RDS metrics
- Automatic email alerts when thresholds are breached
- Application error rate monitoring from logs
- No manual log searching — errors trigger alarms automatically
- All monitoring configured as code

Build a complete observability setup using CloudWatch + SNS.

---

## Architecture

```
EC2 Metrics (CPU, NetworkIn/Out, StatusCheck)   ─┐
RDS Metrics (CPU, FreeStorage, Connections)      ─┤──► CloudWatch
App Logs (ERROR pattern count)                   ─┘         │
                                                             ▼
                                                  CloudWatch Alarms (6 alarms)
                                                             │
                                                             ▼
                                                   SNS Topic: cloud-monitoring-alerts
                                                             │
                                                             ▼
                                                   Email Subscription (you@domain.com)

CloudWatch Dashboard: EC2 CPU, EC2 Network, RDS CPU, RDS Connections
```

---

## Project Structure

```
10-aws-cloudwatch-monitoring/
└── terraform/
    ├── main.tf    ← Dashboard, 6 alarms, SNS, log group, log metric filter
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars
```

---

## Step 1 — Update terraform.tfvars

```hcl
alert_email     = "you@yourcompany.com"
ec2_instance_id = "i-0abc123def456789"   # Your EC2 instance ID
rds_identifier  = "cloud-rds-mysql"       # Your RDS identifier
```

---

## Step 2 — Deploy

```bash
cd terraform/
terraform init && terraform apply
```

> ⚠️ You will receive an email from AWS SNS asking you to confirm your subscription. **Click the Confirm subscription link** or alarms won't send emails.

---

## Step 3 — View Dashboard

```bash
terraform output dashboard_url
```

Open the URL in your browser — you'll see 4 metric graphs for EC2 and RDS.

---

## Step 4 — Test an Alarm (force trigger)

```bash
# Force the EC2 CPU alarm to ALARM state (for testing)
aws cloudwatch set-alarm-state \
  --alarm-name "cloud-monitoring-ec2-cpu-high" \
  --state-value ALARM \
  --state-reason "Testing alarm notification"
```

You should receive an email alert within 1 minute.

Reset back to OK:

```bash
aws cloudwatch set-alarm-state \
  --alarm-name "cloud-monitoring-ec2-cpu-high" \
  --state-value OK \
  --state-reason "Resetting alarm state"
```

---

## Step 5 — Test Log Metric Filter

```bash
LOG_GROUP=$(terraform output -raw app_log_group)

# Send test error logs
aws logs create-log-stream \
  --log-group-name "$LOG_GROUP" \
  --log-stream-name "test-stream"

aws logs put-log-events \
  --log-group-name "$LOG_GROUP" \
  --log-stream-name "test-stream" \
  --log-events \
    timestamp=$(date +%s000),message="ERROR: Database connection timeout" \
    timestamp=$(date +%s000),message="ERROR: Payment service unavailable" \
    timestamp=$(date +%s000),message="ERROR: Rate limit exceeded"
```

Wait ~2 minutes — if the alarm threshold (10 errors/min) is breached, you'll get an email.

---

## Verification Checklist

✅ SNS topic created and email subscription confirmed

✅ CloudWatch Dashboard shows 4 metric graphs

✅ 4 alarms created for EC2 (CPU, StatusCheck) and RDS (CPU, FreeStorage)

✅ Log group created with 30-day retention

✅ Log metric filter detecting `ERROR` pattern

✅ Error count alarm triggers on >10 errors/minute

✅ Test alarm state change triggers email notification

---

## Troubleshooting

**No email received for alarm:**
- Confirm SNS subscription (click link in the AWS confirmation email)
- Check SNS → Subscriptions → Status = `Confirmed`

**Dashboard shows "No data":**
- Verify `ec2_instance_id` matches an existing, running instance
- CloudWatch Standard metrics have 5-minute delay

**Log metric filter not counting:**
- Check log events contain the exact word `ERROR` (case-sensitive pattern match)
- Verify `treat_missing_data = notBreaching` prevents false alarm when no logs arrive

---

## Cleanup

```bash
terraform destroy
```

---

## Key Learnings

- CloudWatch Metric Alarms (comparison_operator, evaluation_periods, period, threshold)
- `treat_missing_data = "notBreaching"` (prevent false alarms when logs are absent)
- CloudWatch Dashboard as code (widget coordinates x/y/width/height)
- CloudWatch Log Metric Filter (extract custom metric from log pattern)
- SNS email subscription and confirmation workflow
- `ok_actions` (send recovery notification when alarm returns to OK)
- EC2 metrics (CPUUtilization, StatusCheckFailed, NetworkIn/Out)
- RDS metrics (CPUUtilization, FreeStorageSpace in bytes, DatabaseConnections)
- Custom namespace for application metrics (`ProjectName/Application`)
- `set-alarm-state` for alarm testing without generating real load
