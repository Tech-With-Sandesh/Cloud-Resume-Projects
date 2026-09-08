# Project 09 - AWS SNS + SQS Event-Driven Messaging with Fan-out and DLQ

## Problem Statement

Your e-commerce platform needs an event-driven architecture where:
- A single order event notifies multiple downstream systems simultaneously
- Order processing and notification services are decoupled
- Failed messages are captured in a Dead Letter Queue for investigation
- Lambda automatically processes orders from the queue
- No message loss even if a consumer is temporarily down

Build an SNS fan-out pattern with SQS queues, DLQ, and Lambda consumer.

---

## Architecture

```
Publisher (CLI / Application)
        │
        ▼ Publish event
    SNS Topic: order-events
        │
        ├──── (fan-out) ────────────────────┐
        ▼                                  ▼
SQS Queue: orders             SQS Queue: notifications
(Long polling, DLQ after 3)   (Long polling, DLQ after 3)
        │
        ▼ (Event Source Mapping)
Lambda: order-consumer
(batch_size=10, processes orders)
        │
        ▼ (Failed messages)
SQS DLQ: cloud-messaging-dlq
(14-day retention — investigation)
```

---

## Project Structure

```
09-aws-sns-sqs-messaging/
└── terraform/
    ├── main.tf    ← SNS topic, SQS queues, DLQ, subscriptions, Lambda consumer, IAM
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

## Step 2 — Publish a Test Event to SNS

```bash
SNS_ARN=$(terraform output -raw sns_topic_arn)

aws sns publish \
  --topic-arn "$SNS_ARN" \
  --message '{"orderId":"ORD-001","customerId":"CUST-123","amount":99.99,"items":["item-1","item-2"]}' \
  --subject "New Order"
```

Expected:

```json
{
  "MessageId": "abc123-def456-..."
}
```

---

## Step 3 — Verify Fan-out: Check Both Queues

```bash
ORDERS_URL=$(terraform output -raw orders_queue_url)
NOTIF_URL=$(terraform output -raw notifications_queue_url)

# Check orders queue
aws sqs receive-message --queue-url "$ORDERS_URL" --max-number-of-messages 1

# Check notifications queue
aws sqs receive-message --queue-url "$NOTIF_URL" --max-number-of-messages 1
```

Both queues should contain the same message — proving fan-out is working.

---

## Step 4 — View Lambda Processing Logs

```bash
aws logs tail /aws/lambda/cloud-messaging-order-consumer --follow
```

Expected:

```
[INFO] Processing order: {"orderId": "ORD-001", "customerId": "CUST-123", ...}
```

---

## Step 5 — Test Dead Letter Queue

Send a message that will cause Lambda to fail (invalid JSON):

```bash
aws sqs send-message \
  --queue-url "$ORDERS_URL" \
  --message-body "INVALID_JSON_THAT_WILL_FAIL"
```

After 3 receive attempts (maxReceiveCount=3), the message moves to DLQ:

```bash
DLQ_URL=$(terraform output -raw dlq_url)
aws sqs receive-message --queue-url "$DLQ_URL" --max-number-of-messages 1
```

---

## Verification Checklist

✅ SNS topic created

✅ 2 SQS queues subscribed to SNS (fan-out)

✅ DLQ configured with maxReceiveCount=3

✅ Long polling enabled (receive_wait_time_seconds=20)

✅ SNS publish delivers to both queues simultaneously

✅ Lambda processes orders queue (event source mapping)

✅ Failed messages land in DLQ after 3 retries

---

## Troubleshooting

**Messages not appearing in SQS after SNS publish:**
- Check SQS queue policy allows SNS to SendMessage (verify `aws:SourceArn` condition)
- Verify SNS subscription is `Confirmed` (not `PendingConfirmation`)

**Lambda not processing messages:**
- Check event source mapping is `Enabled` in Lambda console
- Verify Lambda execution role has SQS receive/delete permissions

---

## Cleanup

```bash
terraform destroy
```

---

## Key Learnings

- SNS fan-out pattern (one publish → multiple subscribers simultaneously)
- SQS long polling (`receive_wait_time_seconds=20` — reduces empty receives, cuts cost)
- Dead Letter Queue (DLQ) with `maxReceiveCount=3` (automatic poison message handling)
- `raw_message_delivery=true` (SQS receives raw message body, not SNS envelope)
- Lambda event source mapping (SQS trigger with `batch_size=10`)
- SQS queue policy (allow SNS to SendMessage with SourceArn condition)
- Visibility timeout (30s — prevents double-processing during Lambda execution)
- 14-day DLQ retention for failed message investigation
- Decoupled architecture (publisher doesn't know about consumers)
- Event-driven vs request-driven (async vs sync communication patterns)
