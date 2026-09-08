# Resume Points — Project 01: AWS S3 Static Website with CloudFront CDN

---

## Fresher

- Deployed a production-grade static website on AWS S3 with CloudFront CDN, enforcing HTTPS via ACM SSL certificate and HTTP-to-HTTPS redirect at the CDN layer.
- Configured CloudFront Origin Access Control (OAC) to restrict S3 bucket access exclusively to CloudFront — S3 Block Public Access remains enabled, eliminating direct public access to the origin.
- Requested and validated an AWS Certificate Manager (ACM) public SSL certificate using DNS validation via Route 53 CNAME records.
- Configured Route 53 Alias A records pointing apex and `www` subdomains to the CloudFront distribution for custom domain resolution.

---

## Experienced Cloud Engineer

- Architected a serverless global static website delivery pipeline: S3 (private origin) → CloudFront (400+ edge locations, HTTP→HTTPS redirect) → ACM (DNS-validated TLS) → Route 53 (Alias A records) — zero server management with sub-100ms global latency.
- Implemented CloudFront OAC (Origin Access Control) replacing legacy OAI — scoped S3 bucket policy to allow `s3:GetObject` only from specific CloudFront distribution ARN, enforcing zero direct S3 public access.
- Configured CloudFront custom error pages (403→200 with `/index.html`) for SPA client-side routing support, and documented cache invalidation (`/*`) for zero-downtime content updates.
- Applied `Cache-Control` headers strategy: `no-cache` for HTML (always fresh), `max-age=31536000` for CSS/JS/assets (immutable with hash-based filenames) — optimising bandwidth costs and CDN hit ratio.

---

## LinkedIn Project Description

Deployed a globally distributed static website using AWS S3 + CloudFront + ACM + Route 53. Configured CloudFront Origin Access Control (OAC) to keep S3 private while serving content globally via 400+ edge locations with HTTPS enforced. Requested and DNS-validated an ACM SSL certificate, configured Route 53 Alias records for apex and www subdomains, and documented cache invalidation and WAF integration as production upgrade paths.

---

## GitHub Project Description

AWS S3 + CloudFront CDN Static Website — Private S3 origin with OAC, HTTPS-only via ACM (us-east-1), HTTP→HTTPS redirect, Route 53 Alias DNS, custom SPA error pages, Cache-Control header strategy, and CloudFront Invalidation workflow.

---

## How to Explain in an Interview (30 Seconds)

"I deployed a static website on AWS S3 with CloudFront as the CDN in front of it. The key design decision was keeping the S3 bucket fully private — Block Public Access stays enabled — and using CloudFront OAC so only my specific CloudFront distribution can read from S3. The bucket policy allows S3 GetObject only if the request comes from that CloudFront distribution ARN. HTTPS is enforced via an ACM certificate, and HTTP traffic gets redirected to HTTPS at the CloudFront layer. I also set up Route 53 Alias records for the custom domain and configured cache invalidations for content updates."

---

## Skills Demonstrated

- AWS S3 (Private bucket, OAC-based origin, versioning)
- Amazon CloudFront (Global CDN, OAC, cache behaviours, custom error pages)
- AWS Certificate Manager / ACM (DNS-validated SSL, us-east-1 requirement)
- AWS Route 53 (Alias A records, hosted zones, DNS validation)
- HTTPS enforcement (HTTP → HTTPS redirect at CDN layer)
- Cache-Control header strategy (HTML vs static assets)
- CloudFront Invalidations (cache clearing workflow)
- AWS WAF (Web Application Firewall — production upgrade path)
- S3 Block Public Access (security best practice)
- Cloud cost optimisation (CDN caching reduces S3 GET costs)
