# Resume Points — Project 05: AWS CloudFront CDN with Security Headers

---

## Fresher

- Deployed a production-hardened CloudFront CDN using Terraform with OAC (Origin Access Control) restricting S3 origin access to CloudFront only, with Block Public Access fully enabled on the S3 bucket.
- Configured a CloudFront Response Headers Policy enforcing HSTS (max-age=31536000 + includeSubDomains + preload), X-Frame-Options: DENY, X-XSS-Protection, and Referrer-Policy: strict-origin-when-cross-origin.
- Implemented custom error responses mapping 403 and 404 to /index.html with 200 response code for SPA client-side routing support.
- Enabled S3 versioning and AES256 server-side encryption on the origin bucket for data durability and compliance.

---

## Experienced Cloud Engineer

- Designed a security-hardened CloudFront distribution: OAC with sigv4 signing (replacing legacy OAI), CachingOptimized managed policy, HTTP→HTTPS redirect, IPv6 dual-stack, PriceClass_All — with a separate Response Headers Policy enforcing all OWASP-recommended security headers at the CDN layer.
- Implemented Terraform-managed CloudFront Response Headers Policy with HSTS preload (max-age=31536000), X-Frame-Options: DENY (clickjacking prevention), X-Content-Type-Options: nosniff (MIME-sniffing prevention), and referrer-policy: strict-origin-when-cross-origin — applied globally across all 400+ edge locations.
- Configured custom error response rules (403/404 → 200 /index.html) enabling React/Vue/Angular SPA deep-link navigation without server-side routing, with 300s error caching TTL to prevent origin flooding on 404 storms.
- Documented CloudFront cache invalidation workflow (`aws cloudfront create-invalidation --paths "/*"`) for zero-downtime content updates.

---

## LinkedIn Project Description

Built a production-hardened CloudFront CDN with Terraform — private S3 origin with OAC (sigv4), HTTP→HTTPS redirect, CachingOptimized policy, IPv6 dual-stack. Configured CloudFront Response Headers Policy enforcing OWASP security headers: HSTS (max-age=31536000 + preload), X-Frame-Options: DENY, X-XSS-Protection, X-Content-Type-Options: nosniff, Referrer-Policy. Custom error responses for SPA routing. Cache invalidation workflow for content updates.

---

## GitHub Project Description

AWS CloudFront CDN (Terraform) — Private S3 origin, OAC (sigv4), Response Headers Policy (HSTS preload + X-Frame-Options + XSS + nosniff + Referrer-Policy), CachingOptimized policy, SPA custom error pages, S3 versioning + AES256 encryption.

---

## How to Explain in an Interview (30 Seconds)

"I built a CloudFront CDN distribution with production security hardening. The S3 origin is fully private — CloudFront OAC uses sigv4 signing so only that specific distribution can access S3, not the internet. On top of that, I added a Response Headers Policy that injects security headers at the CDN edge: HSTS with preload so browsers never send HTTP, X-Frame-Options DENY to prevent clickjacking, nosniff to block MIME-type attacks, and a referrer policy for privacy. This means every response globally gets these security headers without any application code changes."

---

## Skills Demonstrated

- Amazon CloudFront (distribution, OAC, cache behaviours, price classes)
- CloudFront Response Headers Policy (HSTS, X-Frame-Options, XSS, nosniff, Referrer-Policy)
- Origin Access Control (OAC) with sigv4 signing
- CachingOptimized managed cache policy
- SPA custom error responses (404→200, SPA routing)
- Cache invalidation (`aws cloudfront create-invalidation`)
- S3 versioning and AES256 server-side encryption
- OWASP security headers (web security best practices)
- HTTP Strict Transport Security (HSTS) with preload
- Terraform (multi-provider, CloudFront resources)
