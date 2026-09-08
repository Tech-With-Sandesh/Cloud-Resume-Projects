# Resume Points — Project 26: GCP Pub/Sub Event Streaming

---

## Fresher

- Implemented a GCP Pub/Sub fan-out pattern with two independent subscriptions on the same topic — order processing subscription (30s ack deadline) and analytics subscription (7-day retention with retain_acked_messages for replay).
- Configured Dead Letter Queue (DLQ) with max_delivery_attempts=5 and exponential retry backoff (10s min → 600s max) on the processing subscription for reliable message delivery.
- Built a Python publisher using `google-cloud-pubsub` with message attributes (order_id, source) and a streaming pull subscriber with automatic acknowledgment on successful processing.
- Set `message_retention_duration = "604800s"` (7 days) on the analytics subscription with `retain_acked_messages = true` enabling historical message replay for pipeline re-processing.

---

## Experienced Cloud Engineer

- Designed a Pub/Sub event streaming architecture: topic (1-day retention) → 2 independent subscriptions (processor: 30s ack deadline, DLQ after 5 attempts, exponential backoff 10-600s; analytics: 60s ack deadline, 7-day retention, retain_acked for replay) — decoupled consumers with different reliability requirements.
- Implemented DLQ pattern: `dead_letter_policy.max_delivery_attempts=5` + `retry_policy.minimum_backoff=10s/maximum_backoff=600s` — messages that fail 5 times move to DLQ topic; retry backoff prevents thundering herd during transient failures.
- Used streaming pull subscriber (long-lived gRPC connection) for low-latency message consumption vs polling pattern — callback-based processing with `message.ack()` on success, automatic `message.nack()` on exception for retry.

---

## LinkedIn Project Description

Built a GCP Pub/Sub fan-out architecture — topic (1-day retention) → processing subscription (ack 30s, DLQ after 5 attempts, exponential backoff 10-600s) + analytics subscription (ack 60s, 7-day retention, retain_acked for replay). Python publisher with message attributes. Streaming pull subscriber with ack/nack. Dataflow + GCS for analytics pipeline. Terraform.

---

## How to Explain in an Interview (30 Seconds)

"I built a Pub/Sub fan-out where a single order event topic feeds two independent subscribers. The processing subscriber has a 30-second ack deadline and a dead letter queue — after 5 failed delivery attempts with exponential backoff, the message moves to the DLQ instead of being dropped. The analytics subscriber retains all messages for 7 days including already-acknowledged ones, which enables full pipeline replay if you need to reprocess historical data. The key benefit is that these subscribers are completely independent — the analytics subscriber's backlog doesn't affect the processing subscriber's throughput."

---

## Skills Demonstrated

- GCP Pub/Sub (topic, subscriptions, fan-out pattern)
- Dead Letter Queue (max_delivery_attempts, DLQ topic)
- Retry policy (exponential backoff, min/max backoff)
- retain_acked_messages (replay capability for analytics)
- Streaming pull subscriber (long-lived gRPC, callback)
- Message acknowledgment (ack/nack — delivery vs retry)
- Message attributes (metadata with published messages)
- message_retention_duration (topic-level vs subscription-level)
- Python google-cloud-pubsub SDK (PublisherClient, SubscriberClient)
- Cloud Dataflow + Pub/Sub (streaming ETL pattern)
