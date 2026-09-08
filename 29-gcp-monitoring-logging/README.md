# Project 29 - GCP Cloud Monitoring: Alert Policies, Log-Based Metrics and Log Sinks

## Problem Statement

Your GCP production environment needs full observability:
- Alert when VM CPU exceeds 80% for 5 minutes
- Alert when Cloud Run 5xx error rate exceeds 1%
- Alert when application error logs exceed 10/minute
- Archive all Cloud Audit Logs to GCS for 90-day compliance retention
- Email notification for all alerts

---

## Architecture

```
GCP Resources (VM, Cloud Run, Cloud Functions)
        │
        ├── Metric Alerts (VM CPU > 80%, Cloud Run 5xx > 1%)
        ├── Log-Based Metric (severity>=ERROR → custom metric)
        │   └── Alert Policy (app error count > 10/min)
        └── Log Sink (Audit Logs → GCS archive, 90-day lifecycle)
                │
                ▼
        Notification Channel: email
                │
                ▼
        Alert email → ops-team@company.com
```

---

## Project Structure

```
29-gcp-monitoring-logging/
└── terraform/
    ├── main.tf    ← Notification channel, 3 alert policies, log-based metric, log sink, GCS
    ├── variables.tf
    └── outputs.tf
```

---

## Step 1 — Deploy

```bash
export TF_VAR_alert_email="ops@yourcompany.com"

cd terraform/
terraform init
terraform apply -var="project_id=YOUR_PROJECT_ID"
```

---

## Step 2 — Test Alert (Force Trigger)

```bash
# Trigger CPU alert in test mode via Cloud Monitoring
gcloud alpha monitoring policies test \
  --project YOUR_PROJECT_ID \
  $(terraform output -raw notification_channel)
```

Or manually generate load on a GCE instance:

```bash
stress --cpu 4 --timeout 360 &
```

---

## Step 3 — Write Test Error Logs

```bash
gcloud logging write app-logs "ERROR: Database connection failed" \
  --project YOUR_PROJECT_ID \
  --severity ERROR
```

After writing 10+ ERROR logs in 1 minute, the app_error_count alert triggers.

---

## Step 4 — View Log Archive

```bash
BUCKET=$(terraform output -raw log_archive_bucket)
gsutil ls -r "gs://$BUCKET/"
```

Audit logs appear within 5 minutes of GCP activity.

---

## Step 5 — View Cloud Monitoring Dashboards

1. Cloud Console → **Monitoring** → **Dashboards** → **GCE VM Instances**
2. Cloud Console → **Monitoring** → **Alert policies** → verify 3 policies `Enabled`
3. Cloud Console → **Logging** → **Logs Router** → verify `gcs-audit-sink`

---

## Verification Checklist

✅ Email notification channel created

✅ VM CPU alert policy (>80%, 5-minute duration, WARNING)

✅ Cloud Run 5xx alert policy (>1%, 2-minute duration, ERROR)

✅ Log-based metric `app_error_count` created

✅ App error alert (>10/min, CRITICAL)

✅ Log sink to GCS bucket with 90-day lifecycle

✅ Sink writer identity has `storage.objectCreator` on bucket

---

## Troubleshooting

**No email alert received:**
- Verify email notification channel is confirmed (GCP may send a confirmation)
- Check alert policy is in `Enabled` state in Cloud Monitoring

**Log sink not writing to GCS:**
- Ensure `google_storage_bucket_iam_member` grants `objectCreator` to `google_logging_project_sink.writer_identity`
- Verify `unique_writer_identity = true` is set on the sink

**Log-based metric not counting:**
- Test log filter: Cloud Logging → Logs Explorer → paste the filter from `google_logging_metric.filter`
- Verify logs are being written to the correct log name

---

## Cleanup

```bash
terraform destroy -var="project_id=YOUR_PROJECT_ID"
```

---

## Key Learnings

- Cloud Monitoring Alert Policy (conditions, filter, threshold, duration, severity)
- Notification Channels (email type, labels)
- GCP metric filters (resource.type, metric.type, metric.labels)
- Log-based Metrics (DELTA/GAUGE, custom metric from log filter)
- Logging Project Sink (filter, destination, unique_writer_identity)
- Sink writer identity (auto-created SA — must grant GCS permission)
- GCS log archive (90-day lifecycle for compliance)
- Cloud Run request metrics (run.googleapis.com/request_count, response_code_class)
- `ALIGN_RATE` vs `ALIGN_MEAN` aggregation (rate per second vs average)
- Alert policy documentation (runbook content in alert notification)
