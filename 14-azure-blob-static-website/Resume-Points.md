# Resume Points — Project 14: Azure Blob Storage Static Website

---

## Fresher

- Deployed a static website on Azure Blob Storage by enabling `$web` container static website hosting with index.html and 404 document configuration.
- Used `az storage blob upload-batch` with Cache-Control headers to upload all website files to the `$web` container in a single command.
- Created an Azure CDN endpoint (Standard_Microsoft tier) in front of the Blob static website origin for global content delivery and HTTPS support.
- Verified CDN cache hit using `x-cache: TCP_HIT` response header.

---

## Experienced Cloud Engineer

- Hosted a static website on Azure Blob Storage with CDN: StorageV2 account → `$web` container (static website hosting, index/404 documents) → Azure CDN (Standard_Microsoft, custom origin host header matching storage primary endpoint) — serverless, auto-scaling, global delivery.
- Configured `Cache-Control: public, max-age=3600` during upload-batch for proper browser and CDN caching, reducing origin requests.
- Documented HTTPS custom domain setup (Azure CDN + DigiCert/BYO certificate), CDN cache purge workflow, and Azure Front Door as an alternative to Azure CDN for advanced WAF/multi-origin scenarios.

---

## LinkedIn Project Description

Hosted a static website on Azure Blob Storage with Azure CDN — StorageV2 account, $web container (static website hosting enabled), bulk file upload with Cache-Control headers, Azure CDN endpoint (Standard_Microsoft tier) for global HTTPS delivery. CDN cache verification via x-cache header and cache purge workflow.

---

## How to Explain in an Interview (30 Seconds)

"I hosted a static website on Azure Blob Storage. The key is enabling the static website feature on the storage account, which creates a special `$web` container and gives you a public endpoint. I uploaded the HTML and CSS files to that `$web` container with Cache-Control headers for browser caching. Then I added an Azure CDN in front of it so the content is served from edge locations globally with HTTPS — because the native Blob endpoint only supports HTTP for custom domains."

---

## Skills Demonstrated

- Azure Blob Storage ($web container, static website hosting)
- Azure Storage Account (StorageV2, Standard_LRS, public access)
- az storage blob upload-batch (bulk upload with headers)
- Azure CDN (profile, endpoint, Standard_Microsoft tier)
- Cache-Control headers (browser and CDN caching)
- CDN cache purge (invalidation workflow)
- Azure CDN HTTPS (managed certificate on azureedge.net)
- Azure CLI (storage commands, CDN commands)
- Custom domain + HTTPS (Azure CDN + DigiCert)
