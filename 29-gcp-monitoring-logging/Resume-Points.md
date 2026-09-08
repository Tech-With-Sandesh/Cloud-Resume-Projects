# Resume Points — Project 29: GCP Cloud Monitoring and Logging

---

## Fresher

- Configured 3 GCP Cloud Monitoring alert policies using Terraform: VM CPU >80% (5-min duration, WARNING), Cloud Run 5xx error rate >1% (2-min duration, ERROR), and application error count >10/min from log-based metric (CRITICAL).
- Created a log-based metric extracting error counts from Cloud Logging using a severity filter (`severity >= ERROR`) — enabling alerting on application error rates without custom instrumentation code.
- Set up a logging project sink routing Cloud Audit Logs to GCS with `unique_writer_identity = true` and granted the auto-created sink service account `storage.objectCreator` on the destination bucket.
- Applied 90-day lifecycle policy on the GCS log archive bucket to automatically delete old audit logs — balancing compliance retention with storage costs.

---

## Experienced Cloud Engineer

- Designed a multi-layer GCP observability system: infrastructure metrics (VM CPU, ALIGN_MEAN, 60s alignment) + platform metrics (Cloud Run 5xx ALIGN_RATE, 1% threshold) + log-based custom metric (DELTA, app error count from log filter) — each with appropriate aggregation method and alert duration.
- Implemented Cloud Logging sink with `unique_writer_identity=true`: Cloud Logging creates a dedicated service account per sink; I grant only `storage.objectCreator` (not Storage Admin) to that specific SA on the specific bucket — least-privilege log archival.
- Used ALIGN_RATE aggregator for Cloud Run error rate alerts (errors per second, not count) and ALIGN_MEAN for VM CPU (percentage average) — correct aggregation method prevents false positives from bursty but brief metric spikes.
- Documented Cloud Monitoring Uptime Checks (external HTTP probes), SLO monitoring (error budget alerting), and Error Reporting (automatic exception tracking) as production observability extensions.

---

## LinkedIn Project Description

Built GCP Cloud Monitoring observability using Terraform — 3 alert policies (VM CPU >80% ALIGN_MEAN 5min, Cloud Run 5xx ALIGN_RATE >1% 2min, log-based metric ALIGN_RATE >10/min CRITICAL), email notification channel, log-based metric (severity>=ERROR → DELTA custom metric), log sink (Cloud Audit Logs → GCS, unique_writer_identity, objectCreator grant, 90-day lifecycle).

---

## How to Explain in an Interview (30 Seconds)

"I set up Cloud Monitoring alerts using Terraform. The interesting one is the application error alert — instead of instrumenting code with custom metrics, I created a log-based metric that counts any log entry with severity ERROR or higher. Cloud Monitoring then treats that count as a time series and I can alert on it. I used ALIGN_RATE as the aggregation method so I'm measuring errors per second, not total count, which means a burst of 100 errors followed by silence triggers the alert immediately rather than waiting for an average to build up. For audit log compliance, I created a log sink with unique_writer_identity so Cloud Logging uses its own dedicated service account to write to GCS."

---

## Skills Demonstrated

- Cloud Monitoring Alert Policy (conditions, combiner, severity, duration)
- Notification Channels (email, PagerDuty, Slack — type-based)
- GCP metric filters (resource.type, metric.type, metric.labels)
- ALIGN_MEAN vs ALIGN_RATE (average vs per-second rate aggregation)
- Log-Based Metrics (DELTA type, custom metric from log filter)
- Cloud Logging Project Sink (filter, destination, unique_writer_identity)
- Sink writer identity IAM (storage.objectCreator — least-privilege)
- GCS lifecycle policy (90-day compliance retention)
- Cloud Run metrics (request_count, response_code_class 5xx)
- Alert policy documentation (runbook content)
- Cloud Monitoring SLO (error budget alerting — production path)
