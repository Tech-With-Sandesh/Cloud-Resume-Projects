# Resume Points — Project 27: GCP Cloud Storage + Cloud CDN

---

## Fresher

- Deployed a static website on GCP Cloud Storage with Cloud CDN using Terraform — GCS backend bucket (CACHE_ALL_STATIC mode, 1-hour TTL), Global Load Balancer with static IP, and public read IAM binding.
- Configured CORS on the GCS bucket allowing GET/HEAD requests from all origins for browser-based API calls to the bucket.
- Set differentiated Cache-Control headers: `max-age=3600` for HTML (refreshed every hour) and `max-age=86400` for CSS (cached 24 hours) — optimising CDN hit ratio vs content freshness.
- Used `serve_while_stale = 86400` on CDN policy for resilience — CDN serves stale cached content for up to 24 hours if the origin is unavailable.

---

## Experienced Cloud Engineer

- Architected a GCP CDN architecture: GCS bucket (uniform_bucket_level_access=true, website config, CORS) → Backend Bucket (enable_cdn=true, CACHE_ALL_STATIC, negative_caching=true) → URL Map → Target HTTP Proxy → Global Forwarding Rule (static anycast IP) — full Terraform-managed global HTTP(S) Load Balancer.
- Implemented Cloud CDN negative caching (`negative_caching=true`) to cache 404/410 responses at edge, preventing repeated origin hits for missing resources.
- Configured `serve_while_stale = 86400` for high availability: CDN serves stale content for up to 24 hours when origin is unavailable — ensuring website stays up during GCS outages or planned maintenance.
- Documented HTTPS upgrade path (google_compute_managed_ssl_certificate + HTTPS forwarding rule), Cloud Armor WAF for DDoS protection, and custom domain with Cloud DNS.

---

## LinkedIn Project Description

Deployed a GCP static website on Cloud Storage with Cloud CDN — GCS website bucket (uniform IAM, CORS, Cache-Control per content type), Backend Bucket (CACHE_ALL_STATIC, 1h TTL, negative_caching, serve_while_stale 24h), Global HTTP Load Balancer (URL Map + HTTP Proxy + Forwarding Rule, static anycast IP). Cache invalidation workflow. Terraform deployment. Production: HTTPS (managed SSL), Cloud Armor WAF.

---

## How to Explain in an Interview (30 Seconds)

"I hosted a static website on GCP Cloud Storage with Cloud CDN and a Global Load Balancer. The important design detail is the serve_while_stale setting on the CDN — if GCS has an outage or is slow to respond, the CDN will serve the cached version for up to 24 hours instead of showing users an error. I also set different Cache-Control values for different file types: HTML gets 1 hour because it changes more often, while CSS gets 24 hours because it changes rarely and can be immutably cached with hash-based filenames in production."

---

## Skills Demonstrated

- GCP Cloud Storage website hosting (main_page_suffix, not_found_page)
- uniform_bucket_level_access (modern IAM, no legacy object ACLs)
- CORS configuration (origins, methods, headers, max_age)
- Cloud CDN (CACHE_ALL_STATIC, TTL config, negative_caching)
- serve_while_stale (CDN resilience during origin downtime)
- Global External HTTP(S) Load Balancer (URL Map, proxy, forwarding rule)
- Static anycast global IP (google_compute_global_address)
- Cache-Control headers (differentiated TTLs for HTML vs assets)
- CDN cache invalidation (gcloud compute url-maps invalidate-cdn-cache)
- Managed SSL certificate (HTTPS upgrade path)
