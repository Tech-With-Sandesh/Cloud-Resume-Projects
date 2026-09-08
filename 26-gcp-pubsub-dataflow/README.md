# Project 26 - GCP Pub/Sub Event Streaming with Dead Letter Queue and Multiple Subscribers

## Problem Statement

Your event-driven platform needs:
- Publish order events to a central topic
- Multiple subscribers consuming the same event stream independently
- Failed messages captured in a Dead Letter Queue (max 5 attempts)
- Analytics subscriber retaining messages 7 days for replay
- Exponential retry backoff for transient failures

Build a Pub/Sub fan-out architecture with DLQ and retry policies.

---

## Architecture

```
Publisher (publisher.py)
  │
  ▼ Publish to topic
Pub/Sub Topic: order-events (1-day retention)
  │
  ├── Subscription: order-events-sub
  │   ├── ack_deadline: 30s
  │   ├── DLQ: order-events-dlq (after 5 failed attempts)
  │   └── Retry: 10s min → 600s max (exponential backoff)
  │
  └── Subscription: order-events-analytics-sub
      ├── ack_deadline: 60s
      ├── retain_acked_messages: true (7 days — replay capability)
      └── Used by: Dataflow / BigQuery pipeline

Dataflow job reads from analytics sub → writes to GCS output bucket
```

---

## Project Structure

```
26-gcp-pubsub-dataflow/
├── source-code/
│   ├── publisher.py    ← Publishes order events to Pub/Sub topic
│   └── subscriber.py   ← Pull-based consumer (streaming pull)
└── terraform/
    ├── main.tf   ← Topic, DLQ, 2 subscriptions, GCS buckets
    ├── variables.tf
    └── outputs.tf
```

---

## Prerequisites

```bash
pip install google-cloud-pubsub
gcloud auth application-default login
```

---

## Step 1 — Deploy Infrastructure

```bash
terraform init
terraform apply -var="project_id=YOUR_PROJECT_ID"
```

---

## Step 2 — Publish Events

```bash
python source-code/publisher.py --project YOUR_PROJECT_ID --topic order-events --count 20
```

Expected:

```
Published: ORD-1705312200-0000 → message_id=12345678
Published: ORD-1705312200-0001 → message_id=12345679
...
Published 20 messages to projects/YOUR_PROJECT_ID/topics/order-events
```

---

## Step 3 — Consume Events

```bash
python source-code/subscriber.py --project YOUR_PROJECT_ID --subscription order-events-sub
```

Expected:

```
Received: ORD-1705312200-0000 | customer-0 | $10.0
Received: ORD-1705312200-0001 | customer-1 | $17.77
...
```

---

## Step 4 — Verify Fan-out (Both Subscriptions Receive Messages)

```bash
# Check undelivered message count for analytics sub
gcloud pubsub subscriptions describe order-events-analytics-sub \
  --project YOUR_PROJECT_ID \
  --format="value(numUndeliveredMessages)"
```

Both subscriptions receive all messages independently.

---

## Step 5 — Test Dead Letter Queue

Publish a message and don't acknowledge it (let it retry 5 times):

```bash
gcloud pubsub subscriptions pull order-events-sub \
  --project YOUR_PROJECT_ID \
  --limit 1 \
  # Don't --auto-ack — message will retry and eventually go to DLQ
```

After 5 attempts, check DLQ:

```bash
gcloud pubsub subscriptions pull order-events-dlq-sub \
  --project YOUR_PROJECT_ID \
  --auto-ack \
  --limit 5
```

---

## Verification Checklist

✅ Topic `order-events` created (1-day message retention)

✅ DLQ topic `order-events-dlq` created

✅ Subscription `order-events-sub`: DLQ after 5 attempts, retry backoff 10-600s

✅ Subscription `order-events-analytics-sub`: 7-day retention, retain_acked=true

✅ Publisher sends 20 messages successfully

✅ Subscriber receives and acks messages (streaming pull)

✅ Both subscriptions have independent message backlog

---

## Troubleshooting

**`Permission denied` publishing:**
- Ensure your GCP account has `roles/pubsub.publisher` on the topic

**Messages not appearing in subscription:**
- Verify topic and subscription names match
- Check subscription is attached to the correct topic

---

## Cleanup

```bash
terraform destroy -var="project_id=YOUR_PROJECT_ID"
```

---

## Key Learnings

- GCP Pub/Sub topic (message_retention_duration — topic-level durability)
- Pull subscriptions (ack_deadline, streaming pull vs pull API)
- Dead Letter Queue (dead_letter_policy, max_delivery_attempts=5)
- Retry policy (minimum_backoff, maximum_backoff — exponential jitter)
- retain_acked_messages = true (message replay for analytics)
- Fan-out (multiple independent subscriptions on same topic)
- Message attributes (key-value metadata published with messages)
- Publisher client (batch settings, retry settings for reliability)
- Streaming pull (long-lived connection vs polling)
- Cloud Dataflow + Pub/Sub (streaming ETL pipeline pattern)
