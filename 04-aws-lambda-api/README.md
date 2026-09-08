# Project 04 - AWS Lambda Serverless REST API with API Gateway and DynamoDB

## Problem Statement

Your team needs a scalable REST API for a user management service with:
- Zero server management and automatic scaling
- Pay-per-request pricing (no idle compute costs)
- Sub-millisecond database reads at scale
- CRUD operations for user data

Build a fully serverless REST API using AWS Lambda + API Gateway + DynamoDB.

---

## Architecture

```
Client (curl / Postman / Browser)
      │
      ▼ HTTPS
API Gateway (REST API — prod stage)
      │
      ├── GET  /users        ─┐
      ├── POST /users         ├──► Lambda Function (Python 3.11)
      ├── GET  /users/{id}    │         │
      └── DELETE /users/{id} ─┘         ▼
                                   DynamoDB Table
                                   (PAY_PER_REQUEST)
                                         │
                                   CloudWatch Logs
                                   (Lambda execution logs)
```

---

## Project Structure

```
04-aws-lambda-api/
├── source-code/
│   └── lambda_function.py  ← Serverless Python handler (CRUD routes)
└── terraform/
    ├── main.tf              ← Lambda, API Gateway, DynamoDB, IAM
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars
```

---

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | ≥ 1.3.0 |
| AWS CLI | ≥ 2.0 |
| Python | 3.11 (Lambda runtime — no local install needed) |

---

## Step 1 — Deploy Infrastructure

```bash
cd terraform/
terraform init
terraform validate
terraform plan
terraform apply
```

Copy the `api_endpoint` from the output:

```
api_endpoint = "https://abc123.execute-api.ap-south-1.amazonaws.com/prod/users"
```

---

## Step 2 — Test the API

Set the endpoint as a variable:

```bash
API="https://abc123.execute-api.ap-south-1.amazonaws.com/prod/users"
```

### Create a user (POST)

```bash
curl -X POST "$API" \
  -H "Content-Type: application/json" \
  -d '{"name": "Alice", "email": "alice@example.com"}'
```

Expected:

```json
{
  "message": "User created",
  "user": {
    "id": "1705312200000",
    "name": "Alice",
    "email": "alice@example.com",
    "created_at": "2024-01-15T10:30:00"
  }
}
```

### List all users (GET)

```bash
curl "$API"
```

### Get a specific user (GET)

```bash
curl "$API/1705312200000"
```

### Delete a user (DELETE)

```bash
curl -X DELETE "$API/1705312200000"
```

---

## Step 3 — View Lambda Logs

```bash
aws logs tail /aws/lambda/serverless-api-api --follow
```

---

## Verification Checklist

✅ Lambda function deployed and `Active`

✅ API Gateway stage `prod` deployed

✅ DynamoDB table created (`PAY_PER_REQUEST`)

✅ POST /users — creates user and returns 201

✅ GET /users — returns list of users

✅ GET /users/{id} — returns specific user or 404

✅ DELETE /users/{id} — deletes user or returns 404

✅ CloudWatch Logs — Lambda invocation logs visible

---

## Troubleshooting

**502 Bad Gateway from API Gateway:**
- Check Lambda CloudWatch Logs for Python exceptions
- Verify `lambda_function.lambda_handler` matches your handler in `main.tf`

**`AccessDeniedException` in Lambda logs:**
- Verify IAM policy allows DynamoDB actions on the correct table ARN

**`{"message": "Internal Server Error"}`:**
- Enable API Gateway execution logging in the stage settings for full request/response logs

---

## Cleanup

```bash
cd terraform/
terraform destroy
```

---

## Production Notes

> **1. Add API Key or Cognito Authoriser**
> ```hcl
> authorization = "COGNITO_USER_POOLS"
> authorizer_id = aws_api_gateway_authorizer.cognito.id
> ```

> **2. Use Lambda Layers for Dependencies**
> Package shared libraries (boto3, requests) as a Lambda Layer to reduce deployment package size.

> **3. Add X-Ray Tracing**
> ```hcl
> tracing_config { mode = "Active" }
> ```
> Provides end-to-end request tracing across API Gateway → Lambda → DynamoDB.

---

## Key Learnings

- AWS Lambda function (handler, runtime, memory, timeout, environment variables)
- API Gateway REST API (resources, methods, AWS_PROXY integration)
- Lambda permission for API Gateway (`lambda:InvokeFunction`)
- DynamoDB PAY_PER_REQUEST billing (no capacity planning)
- DynamoDB Point-in-Time Recovery (PITR)
- IAM least-privilege role (Lambda → DynamoDB specific actions only)
- `archive_file` Terraform data source (auto-zip Lambda code)
- `source_code_hash` for Lambda code change detection
- Structured logging with Python `logging` module in Lambda
- API Gateway stages and deployment lifecycle
