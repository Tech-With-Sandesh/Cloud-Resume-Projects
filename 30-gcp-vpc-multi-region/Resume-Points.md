# Resume Points — Project 30: GCP VPC Multi-Region Network

---

## Fresher

- Designed a GCP global VPC spanning 3 regions (us-central1, europe-west1, asia-southeast1) with non-overlapping CIDR subnets (10.1/10.2/10.3 /24) using Terraform.
- Configured Cloud NAT with Cloud Router for outbound internet from private instances (no public IP) — AUTO_ONLY IP allocation so GCP manages NAT IPs automatically.
- Restricted SSH access using IAP firewall rule (`35.235.240.0/20`) — only Identity-Aware Proxy tunnel can reach port 22, eliminating public SSH exposure entirely.
- Enabled VPC Flow Logs with 50% sampling and INCLUDE_ALL_METADATA for network traffic analysis without capturing all flows (cost optimisation).

---

## Experienced Cloud Engineer

- Architected a global GCP VPC: `routing_mode=GLOBAL` (dynamic routes visible in all regions), `auto_create_subnetworks=false` (custom CIDR control), 3 regional subnets, VPC Flow Logs (50% sample, 5-second aggregation), firewall rules (internal 10.0.0.0/8, HTTP/HTTPS to web-server tag, SSH to IAP CIDR 35.235.240.0/20 only), Cloud Router + Cloud NAT per region.
- Implemented IAP SSH pattern: firewall allows port 22 only from `35.235.240.0/20` (Google's IAP tunnel relay CIDR) — VMs have no public IP and no public port 22; engineers SSH via `gcloud compute ssh --tunnel-through-iap` through Google's authenticated relay, eliminating bastion hosts.
- Leveraged GCP's global VPC architecture: VMs in us-central1 and europe-west1 communicate directly via 10.x private IPs across Google's backbone — no VPN tunnels, VNet peering, or transit gateways needed (unlike AWS/Azure multi-region architectures).
- Configured VPC Flow Logs at 50% sampling rate (INTERVAL_5_SEC) — captures half of all flows for analysis while reducing Cloud Logging ingestion costs by 50% vs full sampling.

---

## LinkedIn Project Description

Designed a GCP global VPC using Terraform — routing_mode=GLOBAL, auto_create_subnetworks=false, 3 regional subnets (us-central1/europe-west1/asia-southeast1, non-overlapping /24 CIDRs), VPC Flow Logs (50% sample, INCLUDE_ALL_METADATA), firewall rules (internal 10.0.0.0/8, HTTP/HTTPS with target_tags, SSH via IAP CIDR 35.235.240.0/20 only), Cloud Router + Cloud NAT (AUTO_ONLY) per region. Private VMs (no-address) SSH via IAP without public port 22.

---

## How to Explain in an Interview (30 Seconds)

"One of the unique things about GCP networking is that a single VPC spans all regions globally — unlike AWS or Azure where a VPN or peering is needed for cross-region connectivity. I created one VPC with routing_mode=GLOBAL and subnets in three regions. VMs in the US can ping VMs in Europe using private IPs directly over Google's backbone. For SSH, I didn't expose port 22 publicly at all — instead I use Identity-Aware Proxy. The firewall allows SSH only from the IAP relay CIDR, so engineers SSH through Google's authenticated tunnel using gcloud compute ssh --tunnel-through-iap, and VMs have zero public IP addresses."

---

## Skills Demonstrated

- GCP Global VPC (routing_mode=GLOBAL, cross-region private routing)
- Custom VPC mode (auto_create_subnetworks=false, CIDR control)
- VPC Flow Logs (sampling rate, aggregation interval, metadata)
- Cloud Router (dynamic routing, BGP, required for Cloud NAT)
- Cloud NAT (AUTO_ONLY, private outbound internet, no EIP)
- IAP Tunneling (SSH without public port 22 — replaces bastion hosts)
- Firewall target tags (web-server — only tagged VMs receive HTTP)
- IAP CIDR firewall rule (35.235.240.0/20)
- Private VMs (no-address — zero attack surface)
- Cross-region GCP backbone routing (no VPN/peering needed)
- GCP vs AWS/Azure networking (global VPC is unique to GCP)
