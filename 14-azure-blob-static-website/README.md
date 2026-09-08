# Project 14 - Azure Blob Storage Static Website with Azure CDN

## Problem Statement

Host a static website on Azure with:
- No servers to manage
- Global CDN delivery with low latency
- HTTPS with custom domain support
- Cost-effective (pennies per month for small sites)

---

## Architecture

```
User (HTTPS)
  │
  ▼
Azure CDN Endpoint (global PoPs)
  │  ← HTTPS, custom domain, caching
  ▼
Azure Storage Account
  └── $web container (static website hosting)
      ├── index.html
      └── style.css
```

---

## Project Structure

```
14-azure-blob-static-website/
└── source-code/
    ├── index.html
    └── style.css
```

---

## Prerequisites

| Tool | Install |
|------|---------|
| Azure CLI | [learn.microsoft.com](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) |
| Azure Account | [azure.microsoft.com/free](https://azure.microsoft.com/free/) |

---

## Step 1 — Login and Create Resource Group

```bash
az login

az group create \
  --name static-website-rg \
  --location eastus
```

---

## Step 2 — Create Storage Account

```bash
STORAGE_ACCOUNT="mystaticsite$(openssl rand -hex 4)"
echo "Storage account: $STORAGE_ACCOUNT"

az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group static-website-rg \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access true
```

---

## Step 3 — Enable Static Website Hosting

```bash
az storage blob service-properties update \
  --account-name "$STORAGE_ACCOUNT" \
  --static-website \
  --index-document index.html \
  --404-document index.html
```

Get the website endpoint:

```bash
az storage account show \
  --name "$STORAGE_ACCOUNT" \
  --resource-group static-website-rg \
  --query "primaryEndpoints.web" \
  --output tsv
```

Expected:

```
https://mystaticsite1234.z13.web.core.windows.net/
```

---

## Step 4 — Upload Website Files

```bash
az storage blob upload-batch \
  --account-name "$STORAGE_ACCOUNT" \
  --source source-code/ \
  --destination '$web' \
  --content-cache-control "public, max-age=3600"
```

---

## Step 5 — Test Static Website

```bash
WEBSITE_URL=$(az storage account show \
  --name "$STORAGE_ACCOUNT" \
  --resource-group static-website-rg \
  --query "primaryEndpoints.web" \
  --output tsv)

curl "$WEBSITE_URL"
```

---

## Step 6 — Add Azure CDN (Optional but Recommended)

```bash
# Create CDN profile
az cdn profile create \
  --name "static-site-cdn" \
  --resource-group static-website-rg \
  --sku Standard_Microsoft

# Create CDN endpoint
az cdn endpoint create \
  --name "mystaticsite-cdn" \
  --profile-name "static-site-cdn" \
  --resource-group static-website-rg \
  --origin "$(echo $WEBSITE_URL | sed 's|https://||' | sed 's|/||')" \
  --origin-host-header "$(echo $WEBSITE_URL | sed 's|https://||' | sed 's|/||')"
```

CDN endpoint URL:

```
https://mystaticsite-cdn.azureedge.net
```

---

## Step 7 — Verify CDN Delivery

```bash
curl -I https://mystaticsite-cdn.azureedge.net

# Expected header:
# x-cache: TCP_HIT
```

---

## Verification Checklist

✅ Storage account created (StorageV2, Standard_LRS)

✅ Static website hosting enabled

✅ `$web` container contains index.html and style.css

✅ Website loads at `https://storageaccount.z13.web.core.windows.net/`

✅ CDN endpoint created and website loads at `https://endpoint.azureedge.net`

✅ `x-cache: TCP_HIT` header (CDN caching working)

---

## Troubleshooting

**404 Not Found on static website URL:**
- Confirm index.html was uploaded to `$web` container (not to a different container)
- Check static website hosting is `enabled`: `az storage blob service-properties show --account-name $STORAGE_ACCOUNT`

**CDN shows old content:**
- Purge CDN cache: `az cdn endpoint purge --content-paths "/*" --name endpoint --profile-name profile --resource-group rg`

---

## Cleanup

```bash
az group delete --name static-website-rg --yes --no-wait
```

---

## Key Learnings

- Azure Blob Storage static website hosting (`$web` container)
- Azure Storage Account (StorageV2, Standard_LRS, blob public access)
- `az storage blob upload-batch` for bulk file uploads
- Azure CDN profile and endpoint (Standard_Microsoft tier)
- Cache-Control headers for browser and CDN caching
- CDN purge command for cache invalidation
- Azure static website endpoint URL format (`z13.web.core.windows.net`)
- HTTPS via CDN (Azure CDN provides HTTPS on `.azureedge.net` domains)
- Custom domain + HTTPS with Azure CDN and DigiCert certificate
