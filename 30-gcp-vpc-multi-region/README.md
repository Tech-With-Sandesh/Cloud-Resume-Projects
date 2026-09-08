# Project 30 - GCP VPC Multi-Region Network with Cloud NAT, VPC Flow Logs and IAP SSH

## Problem Statement

Your organisation is deploying a globally distributed application and needs:
- A single global VPC spanning 3 regions (US, Europe, Asia)
- Private instances (no public IPs) with outbound internet via Cloud NAT
- SSH access via IAP (no public SSH port 22 exposure)
- VPC Flow Logs for network traffic analysis
- Least-privilege firewall rules

Build a production-grade multi-region GCP VPC using Terraform.

---

## Architecture

```
Single Global VPC: cloud-vpc-global-vpc (routing_mode=GLOBAL)
  │
  ├── Subnet: us-central1    (10.1.0.0/24) + VPC Flow Logs (50% sample)
  ├── Subnet: europe-west1   (10.2.0.0/24) + VPC Flow Logs
  └── Subnet: asia-southeast1 (10.3.0.0/24)
  │
  Firewall Rules:
  ├── allow-internal: all TCP/UDP/ICMP from 10.0.0.0/8 (internal only)
  ├── allow-http-https: 80/443 from 0.0.0.0/0 → tag:web-server
  └── allow-ssh-iap: port 22 from 35.235.240.0/20 (IAP CIDR only)
  │
  Cloud NAT (US + EU):
  ├── us-central1: Cloud Router + NAT (AUTO_ONLY, all subnets)
  └── europe-west1: Cloud Router + NAT

GCP's backbone: us-central1 ↔ europe-west1 ↔ asia-southeast1
(private connectivity within the same VPC — no VPN needed)
```

---

## Project Structure

```
30-gcp-vpc-multi-region/
└── terraform/
    ├── main.tf    ← Global VPC, 3 subnets, 3 firewall rules, 2 Cloud Routers + NATs
    ├── variables.tf
    └── outputs.tf
```

---

## Step 1 — Deploy

```bash
gcloud services enable compute.googleapis.com

cd terraform/
terraform init
terraform apply -var="project_id=YOUR_PROJECT_ID"
```

---

## Step 2 — Verify VPC and Subnets

```bash
gcloud compute networks list --project YOUR_PROJECT_ID
gcloud compute networks subnets list --project YOUR_PROJECT_ID \
  --filter="network:cloud-vpc-global-vpc" \
  --format="table(name,region,ipCidrRange)"
```

Expected:

```
NAME                         REGION           IP_CIDR_RANGE
cloud-vpc-global-us-central  us-central1      10.1.0.0/24
cloud-vpc-global-europe-west europe-west1     10.2.0.0/24
cloud-vpc-global-asia-se     asia-southeast1  10.3.0.0/24
```

---

## Step 3 — Create a Private VM (Test Cloud NAT)

```bash
gcloud compute instances create private-vm-us \
  --project YOUR_PROJECT_ID \
  --zone us-central1-a \
  --network cloud-vpc-global-vpc \
  --subnet cloud-vpc-global-us-central \
  --no-address \
  --machine-type e2-micro \
  --image-family debian-12 \
  --image-project debian-cloud
```

VM has no public IP — access only via IAP SSH.

---

## Step 4 — SSH via IAP (No Public IP Required)

```bash
gcloud compute ssh private-vm-us \
  --project YOUR_PROJECT_ID \
  --zone us-central1-a \
  --tunnel-through-iap
```

Test outbound internet via Cloud NAT:

```bash
curl -s https://ifconfig.me  # Returns Cloud NAT's public IP, not a VM public IP
```

---

## Step 5 — Cross-Region Connectivity Test

```bash
# Create a VM in Europe
gcloud compute instances create private-vm-eu \
  --project YOUR_PROJECT_ID \
  --zone europe-west1-b \
  --network cloud-vpc-global-vpc \
  --subnet cloud-vpc-global-europe-west \
  --no-address \
  --machine-type e2-micro

# From us VM, ping the europe VM's private IP
ping 10.2.0.2  # Cross-region via GCP backbone — no VPN needed!
```

---

## Step 6 — View VPC Flow Logs

```bash
gcloud logging read \
  'resource.type="gce_subnetwork" AND log_name=~"compute.googleapis.com/vpc_flows"' \
  --project YOUR_PROJECT_ID \
  --limit 10 \
  --format="value(jsonPayload.connection)"
```

---

## Verification Checklist

✅ Global VPC with routing_mode=GLOBAL

✅ 3 subnets in different regions (non-overlapping CIDRs)

✅ VPC Flow Logs on us-central1 and europe-west1 subnets

✅ Firewall: internal 10.0.0.0/8, HTTP/HTTPS with web-server tag, SSH IAP CIDR only

✅ Cloud Router + Cloud NAT in US and EU

✅ Private VM (no-address) connects to internet via Cloud NAT

✅ IAP SSH works without port 22 exposed to internet

✅ Cross-region ping between private VMs (GCP backbone routing)

---

## Troubleshooting

**IAP SSH `Permission denied`:**
- Grant IAP Tunneling role: `gcloud projects add-iam-policy-binding PROJECT_ID --member="user:EMAIL" --role="roles/iap.tunnelResourceAccessor"`
- Verify firewall rule allows `35.235.240.0/20` on port 22

**Private VM cannot reach internet:**
- Verify Cloud NAT is in `RUNNING` state: `gcloud compute routers get-nat-mapping-info ROUTER_NAME --region us-central1`
- Confirm `source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"`

---

## Cleanup

```bash
# Delete test VMs first
gcloud compute instances delete private-vm-us --zone us-central1-a --quiet
gcloud compute instances delete private-vm-eu --zone europe-west1-b --quiet

# Destroy VPC
terraform destroy -var="project_id=YOUR_PROJECT_ID"
```

---

## Key Learnings

- GCP Global VPC (single VPC spans all regions — unique vs AWS/Azure per-region VNets)
- `routing_mode = "GLOBAL"` (dynamic routes propagate across all regions)
- `auto_create_subnetworks = false` (custom mode — control your CIDRs)
- VPC Flow Logs (aggregation_interval, flow_sampling, INCLUDE_ALL_METADATA)
- Firewall with target_tags (web-server tag — only tagged VMs receive HTTP/HTTPS)
- IAP SSH firewall rule (`35.235.240.0/20` — Identity-Aware Proxy CIDR)
- Cloud NAT (AUTO_ONLY — managed NAT IPs, no EIP management)
- Cloud Router (required for Cloud NAT — BGP-based dynamic routing)
- Private VMs (no public IP, `--no-address`) — reduce attack surface
- Cross-region routing on GCP backbone (no VPN needed within same VPC)
- IAP Tunneling (SSH without public port 22 — alternative to bastion hosts)
