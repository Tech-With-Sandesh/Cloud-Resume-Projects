# Project 05 - AWS CloudFront CDN with Security Headers and S3 Origin

## Problem Statement

Your company's web application needs:
- Global content delivery with low latency (< 50ms from edge)
- HTTPS-only with HTTP Strict Transport Security (HSTS)
- Security headers (X-Frame-Options, XSS Protection, Content-Type sniffing prevention)
- Private S3 origin (not directly accessible)
- SPA routing support (404 → index.html)
- Automated Terraform deployment

Build a production-hardened CloudFront CDN with security headers using Terraform.

---

## Architecture

```
Browser
  │
  ▼ HTTPS only (HTTP redirected)
CloudFront Edge (400+ PoPs globally)
  │
  ├── Response Headers Policy (HSTS, X-Frame-Options, XSS, CSP)
  ├── CachingOptimized Policy
  ├── Custom Error: 403/404 → /index.html (SPA routing)
  │
  ▼ OAC (Origin Access Control — sigv4 signed)
S3 Bucket (private — Block Public Access ON)
  ├── Versioning: Enabled
  └── Encryption: AES256
```

---

## Project Structure

```
05-aws-cloudfront-cdn/
└── terraform/
    ├── main.tf      ← S3 origin, OAC, CloudFront distribution, security headers policy
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

---

## Step 1 — Update Bucket Name

Edit `terraform/terraform.tfvars`:

```hcl
bucket_name = "your-unique-cdn-origin-2024"  # Must be globally unique
```

---

## Step 2 — Deploy

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

> ⚠️ CloudFront distribution takes 5–10 minutes to deploy globally.

Expected outputs:

```
cloudfront_domain          = "d1abc2xyz.cloudfront.net"
cloudfront_distribution_id = "E1ABCDEF2GHIJ"
s3_bucket_name             = "your-unique-cdn-origin-2024"
website_url                = "https://d1abc2xyz.cloudfront.net"
```

---

## Step 3 — Upload a Website

```bash
# Create a simple test page
cat > /tmp/index.html << 'EOF'
<!DOCTYPE html>
<html><body><h1>Hello from CloudFront CDN!</h1></body></html>
EOF

# Upload to S3 with cache headers
aws s3 cp /tmp/index.html \
  s3://$(terraform output -raw s3_bucket_name)/index.html \
  --cache-control "no-cache"
```

---

## Step 4 — Test HTTPS and Security Headers

```bash
DOMAIN=$(terraform output -raw cloudfront_domain)

# Test HTTPS response
curl -I "https://$DOMAIN"
```

Expected headers:

```
HTTP/2 200
strict-transport-security: max-age=31536000; includeSubDomains; preload
x-content-type-options: nosniff
x-frame-options: DENY
x-xss-protection: 1; mode=block
referrer-policy: strict-origin-when-cross-origin
x-cache: Hit from cloudfront
```

---

## Step 5 — Test Cache Invalidation

After updating a file, invalidate the CloudFront cache:

```bash
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"
```

---

## Verification Checklist

✅ S3 bucket private — Block Public Access enabled

✅ CloudFront OAC attached — S3 not directly accessible

✅ HTTPS enforced — HTTP redirects to HTTPS

✅ Security headers present (HSTS, X-Frame-Options, XSS, Referrer-Policy)

✅ `x-cache: Hit from cloudfront` header (CDN caching working)

✅ Custom error pages (403/404 → `/index.html`)

✅ S3 versioning and AES256 encryption enabled

---

## Troubleshooting

**Direct S3 URL shows 403 (expected):**
- S3 public access is blocked. Only CloudFront OAC can access the bucket. This is correct.

**CloudFront shows old content:**
- Run cache invalidation: `aws cloudfront create-invalidation --distribution-id <id> --paths "/*"`

**Custom error 403→200 not working:**
- Ensure the file path in S3 matches exactly what CloudFront requests

---

## Cleanup

```bash
# Empty S3 bucket first
aws s3 rm s3://$(terraform output -raw s3_bucket_name) --recursive

# Destroy infrastructure (disables CloudFront first automatically)
terraform destroy
```

---

## Key Learnings

- CloudFront Response Headers Policy (HSTS, X-Frame-Options, XSS, Referrer-Policy)
- OAC (Origin Access Control) with sigv4 signing — modern replacement for OAI
- CachingOptimized managed policy (`658327ea-...`)
- Custom error responses for SPA routing (403/404 → index.html)
- S3 versioning and AES256 server-side encryption
- Cache invalidation workflow for content updates
- HTTP Strict Transport Security (HSTS) with preload
- `is_ipv6_enabled = true` for dual-stack CDN delivery
- PriceClass_All vs PriceClass_100 (global vs US+EU cost tradeoff)
