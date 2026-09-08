# Project 17 - Azure Functions Serverless REST API with Application Insights

## Problem Statement

Your team needs a serverless REST API with:
- Zero server management and auto-scaling
- Pay-per-execution pricing (Consumption plan)
- Built-in telemetry and distributed tracing
- Python runtime
- HTTP trigger with function-level auth key

Build a serverless API using Azure Functions + Application Insights.

---

## Architecture

```
Client (HTTPS)
  │ ?code=<function-key>
  ▼
Azure Functions (Consumption Plan — Y1 SKU)
  └── HTTP Trigger Function (GET/POST /api/orders)
        │
        ├── Application Insights (telemetry, tracing, live metrics)
        └── Azure Storage Account (function host state)
```

---

## Project Structure

```
17-azure-functions-serverless/
├── source-code/
│   ├── host.json
│   └── HttpTriggerFunction/
│       ├── __init__.py       ← Python HTTP handler (GET/POST orders)
│       └── function.json     ← Trigger binding config
└── terraform/
    ├── main.tf    ← Function App, Consumption Plan, Storage, App Insights
    ├── variables.tf
    └── outputs.tf
```

---

## Prerequisites

| Tool | Install |
|------|---------|
| Azure CLI | [learn.microsoft.com](https://learn.microsoft.com/cli/azure/) |
| Azure Functions Core Tools | `npm install -g azure-functions-core-tools@4` |
| Terraform | ≥ 1.3.0 |

---

## Step 1 — Deploy Infrastructure

```bash
cd terraform/
terraform init && terraform apply
```

Expected outputs:

```
function_app_url  = "https://cloud-functions-func.azurewebsites.net/api/orders"
function_app_name = "cloud-functions-func"
```

---

## Step 2 — Deploy Function Code

```bash
cd source-code/

# Install dependencies
pip install -r requirements.txt --target .python_packages/lib/site-packages

# Deploy to Azure
func azure functionapp publish $(terraform -chdir=../terraform output -raw function_app_name)
```

---

## Step 3 — Get Function Key

```bash
FUNCTION_APP=$(terraform -chdir=terraform output -raw function_app_name)

az functionapp keys list \
  --name "$FUNCTION_APP" \
  --resource-group functions-rg \
  --query "functionKeys.default" \
  --output tsv
```

---

## Step 4 — Test the API

```bash
BASE_URL=$(terraform -chdir=terraform output -raw function_app_url)
FUNCTION_KEY="paste-key-here"

# GET orders
curl "$BASE_URL?code=$FUNCTION_KEY"

# POST new order
curl -X POST "$BASE_URL?code=$FUNCTION_KEY" \
  -H "Content-Type: application/json" \
  -d '{"customer": "Alice", "amount": 99.99}'
```

---

## Step 5 — View Application Insights

1. Azure Portal → Resource group → **Application Insights**
2. **Live Metrics** — real-time request rate, failures, duration
3. **Failures** — exceptions with full stack traces
4. **Performance** — p50/p95/p99 response times

---

## Verification Checklist

✅ Function App deployed on Consumption Plan (Y1 SKU)

✅ Application Insights linked (instrumentation key in app settings)

✅ GET /api/orders returns order list with `?code=<key>`

✅ POST /api/orders creates order (201 Created)

✅ Invalid JSON returns 400 Bad Request

✅ Application Insights → Live Metrics shows requests in real time

---

## Troubleshooting

**401 Unauthorized on function call:**
- Include `?code=<function-key>` in the request URL
- Get the key: `az functionapp keys list --name <name> --resource-group <rg>`

**Function App shows no functions after deploy:**
- Ensure `SCM_DO_BUILD_DURING_DEPLOYMENT=true` in app settings
- Check deployment logs: `func azure functionapp logstream <app-name>`

---

## Cleanup

```bash
cd terraform/
terraform destroy
```

---

## Key Learnings

- Azure Functions Consumption Plan (Y1 SKU — pay per execution, auto-scale to zero)
- Azure Functions HTTP Trigger (bindings in function.json, auth levels)
- Azure Application Insights (auto-instrumentation, live metrics, distributed tracing)
- `SCM_DO_BUILD_DURING_DEPLOYMENT` (remote build for Python dependencies)
- Function-level auth key (`?code=` parameter)
- `func azure functionapp publish` deployment via Core Tools
- host.json (Application Insights sampling, extension bundle)
- Python azure.functions SDK (HttpRequest, HttpResponse)
- Azure Service Plan (Y1 = Consumption, EP1 = Premium for VNet integration)
- Application Insights connection string vs instrumentation key (new vs legacy)
