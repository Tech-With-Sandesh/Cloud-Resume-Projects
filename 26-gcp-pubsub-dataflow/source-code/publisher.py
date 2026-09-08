"""
GCP Pub/Sub Publisher — Publishes order events to a topic.
"""
import json
import time
import argparse
from google.cloud import pubsub_v1
from datetime import datetime


def publish_orders(project_id: str, topic_id: str, count: int = 10):
    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project_id, topic_id)

    for i in range(count):
        order = {
            "order_id":   f"ORD-{int(time.time())}-{i:04d}",
            "customer":   f"customer-{i % 5}",
            "amount":     round(10.0 + (i * 7.77), 2),
            "status":     "placed",
            "created_at": datetime.utcnow().isoformat()
        }
        data = json.dumps(order).encode("utf-8")
        future = publisher.publish(
            topic_path,
            data,
            order_id=order["order_id"],
            source="publisher-script"
        )
        print(f"Published: {order['order_id']} → message_id={future.result()}")
        time.sleep(0.1)

    print(f"\nPublished {count} messages to {topic_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--project",  required=True)
    parser.add_argument("--topic",    default="order-events")
    parser.add_argument("--count",    type=int, default=10)
    args = parser.parse_args()
    publish_orders(args.project, args.topic, args.count)
