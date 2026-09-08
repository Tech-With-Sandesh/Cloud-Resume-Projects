# Resume Points — Project 09: AWS SNS + SQS Event-Driven Messaging

---

## Fresher

- Implemented an SNS fan-out messaging pattern: a single SNS publish delivers simultaneously to an orders SQS queue and a notifications SQS queue — decoupling order processing from notification delivery.
- Configured SQS Dead Letter Queue (DLQ) with maxReceiveCount=3 — messages that fail processing 3 times automatically move to DLQ for investigation without being dropped.
- Enabled SQS long polling (receive_wait_time_seconds=20) to reduce empty ReceiveMessage API calls and cut SQS polling costs.
- Connected Lambda to SQS orders queue via event source mapping with batch_size=10 for automatic order processing without polling code.

---

## Experienced Cloud Engineer

- Architected an event-driven fan-out system: SNS topic → 2 SQS subscribers (orders + notifications) with raw_message_delivery=true, scoped queue policies (SNS SourceArn condition), Lambda event source mapping (batch_size=10), and DLQ with 14-day retention — achieving full decoupling between publisher and consumers.
- Implemented SQS queue policies with `aws:SourceArn` condition restricting SendMessage to the specific SNS topic ARN — preventing other SNS topics or AWS services from injecting messages into the queue.
- Configured Lambda event source mapping with batch processing (batch_size=10): Lambda processes up to 10 SQS messages per invocation, with automatic checkpoint on success and message visibility extension on processing delay.
- Designed failure handling: visibility_timeout=30s (prevents double-processing) + maxReceiveCount=3 (DLQ after 3 failures) + 14-day DLQ retention (investigation window) — no message is dropped, all failures are capturable.

---

## LinkedIn Project Description

Built an event-driven SNS+SQS fan-out architecture on AWS using Terraform: SNS topic (order-events) → SQS fan-out to orders queue + notifications queue (raw_message_delivery, scoped queue policies with SourceArn condition). Lambda event source mapping (batch_size=10) for order processing. DLQ with maxReceiveCount=3 and 14-day retention for poison message handling. Long polling (20s) for cost optimisation.

---

## GitHub Project Description

AWS SNS+SQS Fan-out (Terraform) — SNS topic, 2 SQS subscribers (raw delivery, SourceArn policy), Lambda event source mapping (batch=10), DLQ (maxReceiveCount=3, 14-day retention), long polling. Event-driven order processing pattern.

---

## How to Explain in an Interview (30 Seconds)

"I built a fan-out messaging pattern using SNS and SQS. When an order event is published to the SNS topic, it simultaneously delivers to both an orders queue and a notifications queue — the publisher doesn't need to know there are two consumers. I enabled raw message delivery so the SQS queues get the actual message body, not the SNS envelope wrapper. Lambda polls the orders queue automatically via event source mapping with batches of 10 messages. If a message fails processing 3 times — which is the maxReceiveCount — it automatically moves to the Dead Letter Queue with 14-day retention so we can investigate without losing the message."

---

## Skills Demonstrated

- Amazon SNS (fan-out pattern, topic, publish API)
- Amazon SQS (standard queue, long polling, visibility timeout)
- SNS fan-out (one publish → multiple SQS queues simultaneously)
- Dead Letter Queue (DLQ, maxReceiveCount, retention period)
- raw_message_delivery (SQS receives message body, not SNS envelope)
- SQS queue policy (SourceArn condition — SNS-only access)
- Lambda event source mapping (SQS trigger, batch_size)
- Long polling (receive_wait_time_seconds=20, cost reduction)
- Event-driven architecture (decoupled publisher/consumer)
- Poison message handling (DLQ investigation workflow)
