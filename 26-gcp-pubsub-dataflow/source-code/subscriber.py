"""
GCP Pub/Sub Subscriber — Pull-based consumer for order events.
"""
import json
import argparse
from google.cloud import pubsub_v1


def subscribe_orders(project_id: str, subscription_id: str):
    subscriber = pubsub_v1.SubscriberClient()
    subscription_path = subscriber.subscription_path(project_id, subscription_id)

    def callback(message: pubsub_v1.subscriber.message.Message) -> None:
        data = json.loads(message.data.decode("utf-8"))
        print(f"Received: {data['order_id']} | {data['customer']} | ${data['amount']}")
        message.ack()

    streaming_pull_future = subscriber.subscribe(subscription_path, callback=callback)
    print(f"Listening for messages on {subscription_path}... (Ctrl+C to stop)")

    with subscriber:
        try:
            streaming_pull_future.result(timeout=30)
        except TimeoutError:
            streaming_pull_future.cancel()
            streaming_pull_future.result()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--project",      required=True)
    parser.add_argument("--subscription", default="order-events-sub")
    args = parser.parse_args()
    subscribe_orders(args.project, args.subscription)
