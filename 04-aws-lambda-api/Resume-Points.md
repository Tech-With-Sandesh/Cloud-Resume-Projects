# Resume Points — Project 04: AWS Lambda Serverless REST API

---

## Fresher

- Built a fully serverless REST API using AWS Lambda (Python 3.11), API Gateway, and DynamoDB — handling GET, POST, and DELETE operations with zero server management.
- Configured API Gateway REST API with AWS_PROXY integration, routing HTTP methods and path parameters directly to a single Lambda handler function for all CRUD routes.
- Provisioned DynamoDB table with PAY_PER_REQUEST billing mode and Point-in-Time Recovery (PITR) enabled using Terraform.
- Applied least-privilege IAM role allowing Lambda to access only specific DynamoDB actions (GetItem, PutItem, DeleteItem, Scan) on a single named table ARN.

---

## Experienced Cloud Engineer

- Designed a serverless CRUD API: API Gateway (REST — AWS_PROXY integration, prod stage) → Lambda (Python 3.11, 256MB, 30s timeout) → DynamoDB (PAY_PER_REQUEST, PITR) — scales from zero to millions of requests with no idle compute cost.
- Implemented Lambda handler routing pattern: single function dispatches all routes via `httpMethod` + `path` + `pathParameters` inspection, eliminating per-route Lambda proliferation while maintaining clear separation of concerns.
- Used Terraform `archive_file` data source with `output_base64sha256` for automatic Lambda redeployment on code changes, and scoped API Gateway `source_arn` permission to `rest_api_id/*/*` for least-privilege invocation.
- Structured Lambda response with CORS headers (`Access-Control-Allow-Origin: *`), consistent HTTP status codes (200/201/400/404/500), and Python `logging` module for structured CloudWatch log output.

---

## LinkedIn Project Description

Built a fully serverless REST API on AWS — API Gateway (REST, AWS_PROXY) → Lambda (Python 3.11) → DynamoDB (PAY_PER_REQUEST + PITR). Implemented CRUD user management (GET/POST/DELETE) with single-handler routing, least-privilege IAM, CORS headers, and structured CloudWatch logging. Deployed with Terraform using `archive_file` for automatic code packaging and hash-based change detection.

---

## GitHub Project Description

AWS Serverless REST API — Lambda (Python 3.11) + API Gateway (REST, AWS_PROXY) + DynamoDB (PAY_PER_REQUEST). CRUD routes, single-handler dispatch, least-privilege IAM, PITR, CORS, CloudWatch logging. Terraform: archive_file packaging, source_code_hash, API Gateway stages.

---

## How to Explain in an Interview (30 Seconds)

"I built a serverless REST API with three AWS services. API Gateway receives HTTP requests and proxies them to a single Lambda function using AWS_PROXY integration — the Lambda gets the full HTTP context and returns the full HTTP response. The Lambda routes to the correct CRUD operation based on HTTP method and path. Data is stored in DynamoDB with PAY_PER_REQUEST billing, so there's no capacity planning and no cost when idle. The IAM role only allows the specific DynamoDB operations needed — not full DynamoDB access. Everything is deployed with Terraform, and the archive_file data source automatically packages and redeploys the Lambda whenever the Python code changes."

---

## Skills Demonstrated

- AWS Lambda (Python 3.11, handler routing, environment variables, CloudWatch Logs)
- Amazon API Gateway (REST API, resources, methods, AWS_PROXY integration, stages)
- Amazon DynamoDB (PAY_PER_REQUEST, hash key, PITR, Scan/GetItem/PutItem/DeleteItem)
- IAM least-privilege (Lambda execution role, scoped DynamoDB permissions)
- Terraform archive_file (automatic Lambda zip packaging)
- source_code_hash (Lambda change detection and redeployment)
- CORS headers (API accessibility from browsers)
- Structured logging (Python logging module → CloudWatch)
- API Gateway Lambda permission (resource-based policy)
- Serverless architecture (zero idle cost, auto-scaling)
