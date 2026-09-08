# Resume Points — Project 17: Azure Functions Serverless REST API

---

## Fresher

- Built a serverless REST API with Azure Functions (Python 3.11, HTTP Trigger) on the Consumption Plan — auto-scales from zero, pay-per-execution, no server management.
- Configured HTTP trigger bindings in `function.json` with `authLevel: function` requiring a function key for every request, and custom route `/api/orders` for clean URL design.
- Integrated Azure Application Insights with `APPINSIGHTS_INSTRUMENTATIONKEY` and `APPLICATIONINSIGHTS_CONNECTION_STRING` for automatic request telemetry, exception tracking, and Live Metrics streaming.
- Used `SCM_DO_BUILD_DURING_DEPLOYMENT=true` for server-side pip install of Python dependencies after deployment, avoiding the need to package dependencies locally.

---

## Experienced Cloud Engineer

- Deployed an Azure Function App on Consumption Plan (Y1 SKU) using Terraform: Storage Account (function host state), Application Insights (sampling configuration in host.json), Linux Service Plan (Y1), and app settings wiring — fully automated infrastructure.
- Implemented Azure Functions Python binding model: `function.json` declares HTTP trigger (in binding) and HTTP response ($return binding) with GET/POST methods and custom route; `__init__.py` contains business logic — clean separation between Azure runtime config and application code.
- Applied function-level auth (`authLevel: function`) generating per-function HMAC keys — more granular than admin-level and more secure than anonymous; documented Managed Identity + API Management as production authentication upgrade.
- Documented Premium Plan (EP1) for VNet integration, always-ready instances, and KEDA-based custom scaling as production upgrade from Consumption Plan.

---

## LinkedIn Project Description

Built a serverless REST API using Azure Functions (Python 3.11, HTTP Trigger, Consumption Plan Y1) — function.json bindings (httpTrigger + http response, function auth level, custom route /api/orders), Application Insights auto-instrumentation (Live Metrics, sampling config in host.json), SCM remote build. Terraform: Function App, Storage Account, App Insights, Service Plan. Production: Premium Plan, VNet integration, APIM.

---

## How to Explain in an Interview (30 Seconds)

"I built a serverless REST API with Azure Functions on the Consumption Plan. The function runs only when triggered — there are no always-on servers, and you pay only for the actual executions. The HTTP trigger binding in function.json configures the route, HTTP methods, and auth level. I used function-level auth, which requires a secret key in every request URL. Application Insights is connected automatically and captures every request with timing, errors, and stack traces — you can watch it in real time with Live Metrics even while testing."

---

## Skills Demonstrated

- Azure Functions (HTTP Trigger, Consumption Plan, Python 3.11)
- function.json bindings (httpTrigger, http response, auth level)
- Azure Application Insights (auto-instrumentation, Live Metrics, sampling)
- host.json configuration (sampling, extension bundle)
- Function-level auth keys (?code= parameter)
- SCM_DO_BUILD_DURING_DEPLOYMENT (remote pip install)
- func azure functionapp publish (Core Tools deployment)
- azure.functions Python SDK (HttpRequest, HttpResponse)
- Terraform (azurerm_linux_function_app, service plan Y1)
- Azure Premium Plan (VNet, always-ready, KEDA)
