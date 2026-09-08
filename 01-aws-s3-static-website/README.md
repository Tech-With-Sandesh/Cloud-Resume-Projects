# Project 01 - AWS S3 Static Website with CloudFront CDN and HTTPS

## Problem Statement

Your company needs to host a global marketing website with the following requirements:

- No servers to manage
- HTTPS enforced (no plain HTTP)
- Low latency for global users via CDN
- Custom domain support
- Cost-effective and highly available

Build a production-grade solution using AWS S3 + CloudFront + ACM + Route 53.

---

## Architecture

```
User (HTTPS)
      │
      ▼
Route 53 (DNS — custom domain)
      │
      ▼
CloudFront Distribution
(Global CDN — 400+ edge locations)
      │  ← HTTPS enforced, HTTP → HTTPS redirect
      ▼
ACM SSL Certificate (us-east-1)
      │
      ▼
S3 Bucket (Origin — private)
(Origin Access Control — OAC)
      │
      ▼
index.html + style.css
```

---

## Project Structure

```
01-aws-s3-static-website/
├── policies/
│   └── bucket-policy.json     ← OAC-based bucket policy (CloudFront only)
└── source-code/
    ├── index.html             ← Main website page
    └── style.css              ← Styling
```

---

## Prerequisites

| Tool | Purpose |
|------|---------|
| AWS Account | [Sign up free](https://aws.amazon.com/free/) |
| Custom Domain (optional) | Any registrar or Route 53 |
| AWS CLI (optional) | For upload via CLI |

---

## Step 1 — Create an S3 Bucket (Private)

1. Go to [AWS Console](https://console.aws.amazon.com) → **S3** → **Create bucket**
2. Configure:

| Field | Value |
|-------|-------|
| Bucket name | `my-cloudfront-website-2024` (globally unique) |
| AWS Region | `ap-south-1` (or your region) |
| Block all public access | ✅ **Keep ENABLED** (CloudFront OAC handles access) |

3. Click **Create bucket**

> ⚠️ **Do NOT disable Block Public Access.** With CloudFront OAC, the bucket stays private — only CloudFront can read from it. This is the secure, recommended pattern.

---

## Step 2 — Upload Website Files

### Option A — AWS Console

1. Click your bucket → **Upload** → **Add files**
2. Select `source-code/index.html` and `source-code/style.css`
3. Click **Upload**

### Option B — AWS CLI

```bash
aws s3 sync source-code/ s3://my-cloudfront-website-2024/
```

Expected:

```
upload: source-code/index.html to s3://my-cloudfront-website-2024/index.html
upload: source-code/style.css  to s3://my-cloudfront-website-2024/style.css
```

---

## Step 3 — Request an SSL Certificate in ACM

> ⚠️ **Critical:** CloudFront requires ACM certificates to be in **us-east-1** regardless of your S3 bucket region.

1. Go to **AWS Certificate Manager (ACM)** → **Switch region to `us-east-1`**
2. Click **Request a certificate** → **Public certificate**
3. Fill in:

| Field | Value |
|-------|-------|
| Domain name | `yourdomain.com` |
| Additional name | `www.yourdomain.com` |
| Validation method | DNS validation |

4. Click **Request**
5. Click the certificate → **Create DNS records in Route 53** (if using Route 53) or copy the CNAME values to your DNS provider
6. Wait 2–5 minutes for status to show **Issued**

> ℹ️ If you don't have a custom domain, skip Steps 3 and 7. CloudFront provides a free `*.cloudfront.net` domain over HTTPS.

---

## Step 4 — Create a CloudFront Distribution

1. Go to **CloudFront** → **Create distribution**
2. Configure **Origin**:

| Field | Value |
|-------|-------|
| Origin domain | Select your S3 bucket from the dropdown |
| Origin access | **Origin access control settings (recommended)** |
| Origin access control | Click **Create new OAC** → Name: `my-website-oac` → Create |

3. Configure **Default cache behavior**:

| Field | Value |
|-------|-------|
| Viewer protocol policy | **Redirect HTTP to HTTPS** |
| Cache policy | `CachingOptimized` |

4. Configure **Settings**:

| Field | Value |
|-------|-------|
| Alternate domain name (CNAME) | `yourdomain.com`, `www.yourdomain.com` |
| Custom SSL certificate | Select your ACM certificate (issued in us-east-1) |
| Default root object | `index.html` |

5. Click **Create distribution**

> ℹ️ CloudFront distribution takes 5–10 minutes to deploy globally.

---

## Step 5 — Apply the S3 Bucket Policy

After creating the distribution, CloudFront shows a yellow banner:

```
You must update the S3 bucket policy to allow CloudFront to access the S3 bucket.
```

1. Click **Copy policy** from the CloudFront banner
2. Go to your **S3 bucket** → **Permissions** → **Bucket policy** → **Edit**
3. Paste the copied policy
4. Click **Save changes**

Or paste the policy from `policies/bucket-policy.json` after replacing:
- `YOUR-BUCKET-NAME` → your actual bucket name
- `YOUR-ACCOUNT-ID` → your AWS account ID
- `YOUR-DISTRIBUTION-ID` → your CloudFront distribution ID

---

## Step 6 — Test CloudFront Access

Copy the **Distribution domain name** from CloudFront (e.g., `d1abc2xyz.cloudfront.net`):

```bash
curl -I https://d1abc2xyz.cloudfront.net
```

Expected response headers:

```
HTTP/2 200
content-type: text/html
x-cache: Hit from cloudfront
via: 1.1 abc.cloudfront.net (CloudFront)
```

Open in browser:

```
https://d1abc2xyz.cloudfront.net
```

Expected — your website loads with HTTPS padlock.

---

## Step 7 — Configure Custom Domain in Route 53 (Optional)

1. Go to **Route 53** → **Hosted zones** → your domain
2. Click **Create record**
3. Configure:

| Field | Value |
|-------|-------|
| Record name | (blank = apex domain) |
| Record type | A |
| Alias | ✅ Yes |
| Route traffic to | CloudFront distribution |
| Distribution | Select your distribution |

4. Repeat for `www` subdomain
5. Click **Create records**

Wait 1–2 minutes for DNS propagation:

```bash
curl -I https://yourdomain.com
```

Expected:

```
HTTP/2 200
x-cache: Hit from cloudfront
```

---

## Step 8 — Configure Error Pages (Optional)

For Single Page Applications (SPA) that handle routing client-side:

1. CloudFront → your distribution → **Error pages**
2. Click **Create custom error response**:

| Field | Value |
|-------|-------|
| HTTP error code | 403 |
| Customize error response | Yes |
| Response page path | `/index.html` |
| HTTP Response code | 200 |

Repeat for 404.

---

## Verification Checklist

✅ S3 bucket created with **Block Public Access enabled**

✅ Website files uploaded (`index.html`, `style.css`)

✅ ACM certificate **Issued** in `us-east-1`

✅ CloudFront distribution **Deployed** (status = Enabled)

✅ OAC created and attached to origin

✅ S3 bucket policy updated (allows CloudFront OAC only)

✅ `https://d1abc2xyz.cloudfront.net` loads website with HTTPS

✅ `x-cache: Hit from cloudfront` header present (CDN working)

✅ Custom domain resolves via Route 53 (if configured)

✅ HTTP → HTTPS redirect works (test `http://yourdomain.com`)

---

## Troubleshooting

**403 Access Denied from CloudFront:**
- Verify S3 bucket policy was saved correctly with OAC ARN
- Check the OAC is attached to the correct distribution origin
- Ensure `Default root object` is set to `index.html` in CloudFront settings

**Certificate not showing in CloudFront:**
- Confirm ACM certificate is in **us-east-1** region (not your bucket region)
- Confirm certificate status is **Issued** (not Pending)

**Old content serving (cached):**
- Create a CloudFront Invalidation:
  ```
  CloudFront → Distribution → Invalidations → Create → /*
  ```

**DNS not resolving:**
- Check Route 53 record points to correct CloudFront domain
- DNS TTL may take up to 5 minutes to propagate globally

---

## Cleanup

```bash
# 1. Disable CloudFront distribution first (required before delete)
# CloudFront → Distribution → Disable → Wait for status "Disabled"
# Then: Delete distribution

# 2. Delete ACM certificate
# ACM → Certificate → Delete

# 3. Empty and delete S3 bucket
aws s3 rm s3://my-cloudfront-website-2024 --recursive
aws s3 rb s3://my-cloudfront-website-2024

# 4. Delete Route 53 records (if created)
```

---

## Production Notes

> **1. Enable S3 Versioning**
> ```
> S3 → Bucket → Properties → Bucket Versioning → Enable
> ```
> Allows rollback to previous versions of your website files.

> **2. Add WAF (Web Application Firewall)**
> Attach AWS WAF to your CloudFront distribution to block common web attacks (SQLi, XSS, bad bots).

> **3. Enable Access Logging**
> ```
> CloudFront → Distribution → Edit → Standard logging → Enable → S3 log bucket
> ```
> Track visitor IPs, geolocation, cache hit/miss ratios.

> **4. Set Cache-Control Headers**
> Upload files with appropriate `Cache-Control` headers for browser caching:
> ```bash
> aws s3 cp index.html s3://bucket/ --cache-control "no-cache"
> aws s3 cp style.css  s3://bucket/ --cache-control "max-age=31536000"
> ```

---

## Key Learnings

- AWS S3 private bucket with OAC (Origin Access Control — modern replacement for OAI)
- CloudFront distribution creation and global CDN edge caching
- ACM SSL certificate in `us-east-1` (CloudFront requirement)
- HTTP → HTTPS redirect enforcement at CDN layer
- Route 53 Alias A record pointing to CloudFront
- CloudFront Invalidations for cache clearing
- S3 Block Public Access with OAC-only access (security best practice)
- Custom error pages for SPA routing support
- Cache-Control headers for optimal browser + CDN caching
