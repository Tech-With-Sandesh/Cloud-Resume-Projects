# Resume Points — Project 12: AWS Serverless Data Pipeline

---

## Fresher

- Built a serverless data pipeline using S3 event notifications → Lambda (Python 3.11) → S3 with date-partitioned output prefixes (`processed/YYYY/MM/DD/`), eliminating all server management for data transformation.
- Implemented S3 bucket notification with prefix (`incoming/`) and suffix (`.json`) filters to trigger Lambda only for relevant files, preventing noise from other uploads.
- Configured S3 lifecycle policy on the processed bucket — transition to GLACIER after 90 days, delete after 365 days — reducing long-term storage costs by up to 80%.
- Set up Amazon Athena workgroup with S3 results location for serverless SQL querying of processed JSON files without any database infrastructure.

---

## Experienced Cloud Engineer

- Designed a fully serverless ETL pipeline: S3 event notification (ObjectCreated + prefix/suffix filter) → Lambda (S3 GetObject → transform → PutObject with date-partitioned key) → Athena workgroup (serverless SQL on S3) — zero servers, scales automatically, pay-per-invocation.
- Implemented `urllib.parse.unquote_plus` for S3 key decoding in Lambda event records (prevents processing failures on filenames with spaces or special characters), and `source_arn` in Lambda resource-based policy to prevent confused deputy attacks.
- Applied least-privilege IAM: Lambda role allows `s3:GetObject` only on raw bucket ARN and `s3:PutObject` only on processed bucket ARN — a compromised Lambda cannot read other S3 buckets or overwrite raw data.
- Designed date-partitioned S3 output (`processed/YYYY/MM/DD/`) enabling Athena partition pruning — queries for a specific date scan only that partition's data, reducing Athena query cost significantly.

---

## LinkedIn Project Description

Built a serverless ETL pipeline on AWS — S3 event notifications (ObjectCreated, prefix/suffix filter) → Lambda (Python 3.11: read/transform/enrich/write) → S3 processed bucket (date-partitioned: YYYY/MM/DD, lifecycle: Glacier 90d, delete 365d) → Athena workgroup (serverless SQL). Least-privilege IAM (scoped GetObject/PutObject per bucket). urllib.parse.unquote_plus for S3 key safety. Terraform deployment.

---

## GitHub Project Description

AWS Serverless Data Pipeline — S3 (raw + processed + Athena results), Lambda (S3 trigger with prefix/suffix filter, transform + enrich), date-partitioned output, Glacier lifecycle, Athena workgroup. Least-privilege IAM, confused deputy prevention. Terraform.

---

## How to Explain in an Interview (30 Seconds)

"I built a serverless data pipeline where uploading a JSON file to S3 automatically triggers a Lambda function. The S3 notification has a prefix and suffix filter — only files in the `incoming/` folder with `.json` extension trigger it. The Lambda reads the raw JSON, enriches it with metadata like a timestamp and pipeline version, and writes it to a processed S3 bucket with a date-partitioned key like `processed/2024/01/15/`. This date partitioning is important for Athena — when someone queries data for a specific date, Athena only scans that day's folder instead of all historical data, which reduces both query time and cost."

---

## Skills Demonstrated

- Amazon S3 (event notifications, prefix/suffix filters, versioning, lifecycle)
- AWS Lambda (S3 trigger, Python 3.11, S3 read/write, error handling)
- S3 Lifecycle Policy (GLACIER transition, expiration rules)
- Date-partitioned S3 prefix (Athena partition pruning)
- Amazon Athena (workgroup, S3 result location, external table, JSON serde)
- Serverless ETL (zero server, event-driven, auto-scaling)
- IAM least-privilege (per-bucket GetObject/PutObject scoping)
- urllib.parse.unquote_plus (S3 key encoding safety)
- Confused deputy prevention (source_arn in Lambda permission)
- Glue Data Catalog integration with Athena
- S3 Glacier cost optimisation (long-term storage tiering)
