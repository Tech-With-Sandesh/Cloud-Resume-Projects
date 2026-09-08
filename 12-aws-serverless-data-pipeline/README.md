# Project 12 - AWS Serverless Data Pipeline: S3 → Lambda → S3 → Athena

## Problem Statement

Your data team needs a pipeline to:
- Ingest raw JSON files automatically when uploaded to S3
- Transform and enrich data without servers
- Store processed data in a structured format
- Query processed data using SQL without a database
- Archive old data cost-effectively

Build a fully serverless data pipeline using S3 + Lambda + Athena.

---

## Architecture

```
Data Source (upload JSON)
      │
      ▼ PUT s3://raw-bucket/incoming/*.json
S3 Raw Bucket
      │ (S3 Event Notification → ObjectCreated)
      ▼
Lambda Transform Function (Python 3.11)
      │  - Reads raw JSON from S3
      │  - Enriches with metadata (processed_at, version, source)
      │  - Writes to processed/YYYY/MM/DD/ prefix
      ▼
S3 Processed Bucket
      │  Lifecycle: → GLACIER after 90 days → Delete after 365 days
      │
      ▼
Amazon Athena (Workgroup)
      └── SQL queries on processed JSON files
          Results → s3://athena-results-bucket/results/
```

---

## Project Structure

```
12-aws-serverless-data-pipeline/
├── source-code/
│   └── transform_lambda.py    ← S3-triggered transform + enrich function
└── terraform/
    ├── main.tf                ← S3 buckets, Lambda, S3 notification, Athena
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars
```

---

## Step 1 — Deploy

```bash
cd terraform/
terraform init && terraform apply
```

---

## Step 2 — Upload a Test JSON File

```bash
RAW_BUCKET=$(terraform output -raw raw_bucket)

cat > /tmp/orders.json << 'EOF'
[
  {"orderId": "ORD-001", "customer": "Alice", "amount": 99.99, "status": "placed"},
  {"orderId": "ORD-002", "customer": "Bob",   "amount": 249.50, "status": "placed"}
]
EOF

aws s3 cp /tmp/orders.json "s3://$RAW_BUCKET/incoming/orders.json"
```

Expected:

```
upload: /tmp/orders.json to s3://cloud-data-pipeline-raw-123456789012/incoming/orders.json
```

---

## Step 3 — Verify Lambda Processing

```bash
aws logs tail /aws/lambda/cloud-data-pipeline-transform --follow
```

Expected:

```
[INFO] Processing file: s3://cloud-data-pipeline-raw-.../incoming/orders.json
[INFO] Written to: s3://cloud-data-pipeline-processed-.../processed/2024/01/15/orders.json
```

---

## Step 4 — Verify Processed File

```bash
PROCESSED_BUCKET=$(terraform output -raw processed_bucket)

aws s3 ls "s3://$PROCESSED_BUCKET/processed/" --recursive
aws s3 cp "s3://$PROCESSED_BUCKET/processed/2024/01/15/orders.json" /tmp/processed.json
cat /tmp/processed.json
```

Expected — enriched JSON with metadata:

```json
[
  {
    "orderId": "ORD-001",
    "customer": "Alice",
    "amount": 99.99,
    "status": "placed",
    "processed_at": "2024-01-15T10:30:00",
    "pipeline_version": "1.0",
    "source": "aws-serverless-pipeline"
  }
]
```

---

## Step 5 — Query with Athena

Create a Glue table pointing to the processed S3 bucket, then run SQL in Athena:

```sql
-- Run in Athena Query Editor (select workgroup: cloud-data-pipeline-workgroup)
CREATE EXTERNAL TABLE IF NOT EXISTS orders (
  orderId      STRING,
  customer     STRING,
  amount       DOUBLE,
  status       STRING,
  processed_at STRING
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION 's3://cloud-data-pipeline-processed-123456789012/processed/';

-- Query
SELECT customer, SUM(amount) AS total_spent
FROM orders
GROUP BY customer
ORDER BY total_spent DESC;
```

---

## Verification Checklist

✅ Raw S3 bucket created with versioning

✅ Processed S3 bucket with lifecycle policy (Glacier after 90d)

✅ Lambda trigger fires on `s3:ObjectCreated:*` for `incoming/*.json`

✅ Lambda reads from raw bucket, writes to processed bucket

✅ Processed file contains enriched fields (processed_at, version, source)

✅ Date-partitioned output prefix (processed/YYYY/MM/DD/)

✅ Athena workgroup configured with S3 results location

---

## Troubleshooting

**Lambda not triggered after S3 upload:**
- Verify upload key starts with `incoming/` and ends with `.json` (filter_prefix/suffix)
- Check Lambda permission allows `s3.amazonaws.com` to invoke

**`AccessDenied` in Lambda logs:**
- Confirm IAM role has `s3:GetObject` on raw bucket and `s3:PutObject` on processed bucket

**Athena query returns no results:**
- Verify S3 path in LOCATION matches the actual processed file prefix
- Ensure JSON format matches table schema

---

## Cleanup

```bash
# Empty all buckets first
aws s3 rm s3://$(terraform output -raw raw_bucket) --recursive
aws s3 rm s3://$(terraform output -raw processed_bucket) --recursive
# Destroy
terraform destroy
```

---

## Key Learnings

- S3 event notifications (ObjectCreated → Lambda trigger with prefix/suffix filters)
- Lambda S3 read/write pattern (get_object, put_object, event parsing)
- Date-partitioned S3 prefix (`processed/YYYY/MM/DD/`) for Athena partition efficiency
- S3 lifecycle rules (S3 → GLACIER after 90 days, delete after 365 days)
- Athena workgroup (query isolation, cost control, result location)
- S3 versioning on raw bucket (data lineage and recovery)
- Least-privilege Lambda IAM (GetObject on raw bucket ARN only, PutObject on processed ARN only)
- `source_arn` in Lambda permission (prevent confused deputy attack)
- Glue Data Catalog + Athena (serverless SQL on S3 JSON data)
- urllib.parse.unquote_plus (handle S3 key encoding in event records)
