import azure.functions as func
import json
import logging
from datetime import datetime

logger = logging.getLogger(__name__)


def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    Azure Function HTTP Trigger — Order processing endpoint.
    GET  /api/orders       → list orders (from query params)
    POST /api/orders       → create order
    """
    logger.info("HTTP trigger received: %s %s", req.method, req.url)

    method = req.method.upper()

    try:
        if method == "GET":
            return handle_get(req)
        elif method == "POST":
            return handle_post(req)
        else:
            return func.HttpResponse(
                json.dumps({"error": f"Method {method} not allowed"}),
                status_code=405,
                mimetype="application/json"
            )
    except Exception as e:
        logger.error("Unhandled error: %s", str(e))
        return func.HttpResponse(
            json.dumps({"error": "Internal server error"}),
            status_code=500,
            mimetype="application/json"
        )


def handle_get(req: func.HttpRequest) -> func.HttpResponse:
    status = req.params.get("status", "all")
    orders = [
        {"id": "ORD-001", "customer": "Alice", "amount": 99.99, "status": "placed"},
        {"id": "ORD-002", "customer": "Bob",   "amount": 249.50, "status": "shipped"},
    ]
    if status != "all":
        orders = [o for o in orders if o["status"] == status]

    return func.HttpResponse(
        json.dumps({"orders": orders, "count": len(orders)}),
        status_code=200,
        mimetype="application/json"
    )


def handle_post(req: func.HttpRequest) -> func.HttpResponse:
    try:
        body = req.get_json()
    except ValueError:
        return func.HttpResponse(
            json.dumps({"error": "Invalid JSON body"}),
            status_code=400,
            mimetype="application/json"
        )

    required = ["customer", "amount"]
    missing  = [f for f in required if f not in body]
    if missing:
        return func.HttpResponse(
            json.dumps({"error": f"Missing fields: {missing}"}),
            status_code=400,
            mimetype="application/json"
        )

    order = {
        "id":          f"ORD-{int(datetime.utcnow().timestamp())}",
        "customer":    body["customer"],
        "amount":      body["amount"],
        "status":      "placed",
        "created_at":  datetime.utcnow().isoformat()
    }
    logger.info("Order created: %s", order["id"])

    return func.HttpResponse(
        json.dumps({"message": "Order created", "order": order}),
        status_code=201,
        mimetype="application/json"
    )
