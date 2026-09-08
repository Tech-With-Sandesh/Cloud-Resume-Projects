# Project 27 - GCP Cloud Storage Static Website with Cloud CDN and Global Load Balancer

## Problem Statement

Host a static website on GCP with:
- Global content delivery with low latency
- Cloud CDN for edge caching
- Cache-Control headers for optimal caching
- CORS configuration for API calls
- Global Load Balancer with static IP

---

## Architecture

```
User (Browser)
  │
  ▼ HTTP (port 80)
Global External Load Balancer (static global IP)
  │
  ▼
Cloud CDN (CACHE_ALL_STATIC, 1-hour TTL, serve_while_stale)
  │
  ▼ (cache miss)
Backend Bucket → GCS Bucket (public read)
  └── index.html (cache: 1h)
  └── style.css  (cache: 24h)
```

---

## Project Structure

```
27-gcp-cloud-storage-cdn/
├── source-code/
│   ├── index.html
│   └── style.css
└── terraform/
    ├── main.tf    ← GCS, Backend Bucket, URL Map, HTTP Proxy, Forwarding Rule, Cloud CDN
    ├── variables.tf
    └── outputs.tf
```

---

## Step 1 — Deploy

```bash
gcloud services enable compute.googleapis.com storage.googleapis.com

cd terraform/
terraform init
terraform apply -var="project_id=YOUR_PROJECT_ID"
```

---

## Step 2 — Test Website

```bash
IP=$(terraform output -raw website_ip)
curl "http://$IP"
```

> ℹ️ Load Balancer takes 5–10 minutes to become active globally after creation.

---

## Step 3 — Verify CDN Caching

```bash
curl -I "http://$IP"
```

Expected response headers when cache hits:

```
Age: 120
Cache-Control: public, max-age=3600
Via: 1.1 google
```

---

## Step 4 — Invalidate Cache (after file update)

```bash
gcloud compute url-maps invalidate-cdn-cache $(terraform output -raw url_map) \
  --path "/*" \
  --project YOUR_PROJECT_ID
```

---

## Verification Checklist

✅ GCS bucket created with website configuration (index.html, 404→index.html)

✅ `allUsers` storage.objectViewer IAM binding

✅ Files uploaded with correct Content-Type and Cache-Control headers

✅ Backend Bucket with CDN enabled (CACHE_ALL_STATIC)

✅ Global Load Balancer with static IP

✅ Website accessible at `http://GLOBAL_IP`

✅ CDN cache headers present (`Age`, `Via: 1.1 google`)

---

## Cleanup

```bash
terraform destroy -var="project_id=YOUR_PROJECT_ID"
```

---

## Key Learnings

- GCS website hosting (main_page_suffix, not_found_page)
- `uniform_bucket_level_access = true` (modern IAM, not legacy ACLs)
- `allUsers` IAM for public GCS bucket read
- CORS configuration on GCS (for browser API calls to bucket)
- `google_compute_backend_bucket` with `enable_cdn = true`
- Cloud CDN cache modes (CACHE_ALL_STATIC — caches responses with Cache-Control)
- `serve_while_stale` (CDN serves stale content while revalidating — resilience)
- Global Load Balancer (URL Map → Target HTTP Proxy → Forwarding Rule)
- `cache_control` on GCS objects (different TTLs for HTML vs CSS/JS)
- Cache invalidation (`gcloud compute url-maps invalidate-cdn-cache`)
