# Project 13 - Azure VM with Nginx Web Server (Bicep)

## Problem Statement

Your team needs to host a website on Azure with full control over the server environment:
- Ubuntu VM on Azure
- Nginx web server installed automatically via Custom Script Extension
- SSH key-based authentication (no passwords)
- NSG rules — SSH restricted to your IP, HTTP/HTTPS open
- Static public IP with DNS label
- Infrastructure as Code using Bicep

---

## Architecture

```
Internet
  │
  ▼ Port 80 / 443
Azure NSG (Network Security Group)
  ├── Allow HTTP  (80)  from *
  ├── Allow HTTPS (443) from *
  └── Allow SSH   (22)  from YOUR_IP only
  │
  ▼
Azure Public IP (Standard SKU — Static)
  │
  ▼
Azure NIC → Azure VNet (10.0.0.0/16) → Subnet (10.0.1.0/24)
  │
  ▼
Azure VM (Ubuntu 22.04 LTS — Standard_B1s)
  │
  ▼ Custom Script Extension
Nginx → /var/www/html/index.html
```

---

## Project Structure

```
13-azure-vm-nginx/
├── main.bicep              ← VM, VNet, NSG, Public IP, NIC, Custom Script Extension
└── scripts/
    └── install-nginx.sh    ← Nginx install + website deploy script
```

---

## Prerequisites

| Tool | Install |
|------|---------|
| Azure CLI | [docs.microsoft.com](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) |
| Azure Account | [azure.microsoft.com/free](https://azure.microsoft.com/en-us/free/) |

---

## Step 1 — Login to Azure

```bash
az login
az account show
```

---

## Step 2 — Generate SSH Key Pair

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure-vm-key -N ""
cat ~/.ssh/azure-vm-key.pub
```

Copy the public key — you'll need it in the next step.

---

## Step 3 — Update NSG with Your IP

Edit `main.bicep` and replace `YOUR_IP/32` with your actual public IP:

```bash
curl ifconfig.me
# Example: 203.0.113.45
# Use: 203.0.113.45/32
```

---

## Step 4 — Create Resource Group

```bash
az group create \
  --name nginx-vm-rg \
  --location eastus
```

---

## Step 5 — Deploy Bicep Template

```bash
az deployment group create \
  --resource-group nginx-vm-rg \
  --template-file main.bicep \
  --parameters adminPublicKey="$(cat ~/.ssh/azure-vm-key.pub)" \
  --parameters vmName=nginx-vm
```

> ⚠️ Deployment takes 3–5 minutes (VM provisioning + Custom Script Extension).

Expected outputs:

```json
{
  "publicIPAddress": "20.72.xxx.xxx",
  "fqdn": "nginx-vm-abc123.eastus.cloudapp.azure.com",
  "sshCommand": "ssh azureuser@20.72.xxx.xxx"
}
```

---

## Step 6 — Verify Nginx

```bash
# Test HTTP access
curl "http://$(az deployment group show \
  --resource-group nginx-vm-rg \
  --name main \
  --query properties.outputs.publicIPAddress.value -o tsv)"
```

Expected output:

```html
<h1>Hello from Azure VM!</h1>
```

---

## Step 7 — SSH into the VM

```bash
ssh -i ~/.ssh/azure-vm-key azureuser@20.72.xxx.xxx

# Check Nginx status
systemctl status nginx

# View website file
cat /var/www/html/index.html
```

---

## Verification Checklist

✅ Resource group created in East US

✅ VNet and subnet created (10.0.0.0/16, 10.0.1.0/24)

✅ NSG: HTTP/HTTPS open, SSH restricted to your IP

✅ Static Public IP allocated

✅ VM running Ubuntu 22.04 LTS

✅ Custom Script Extension succeeded (check Extensions in Azure Portal)

✅ Nginx active (running) — `systemctl status nginx`

✅ Website accessible at `http://PUBLIC_IP`

✅ SSH works with key: `ssh -i ~/.ssh/azure-vm-key azureuser@PUBLIC_IP`

---

## Troubleshooting

**Custom Script Extension fails:**
- Check extension logs: Azure Portal → VM → Extensions → InstallNginx → View detailed status
- SSH into VM and check: `cat /var/log/azure/custom-script/handler.log`

**SSH: `Connection refused`:**
- Verify NSG rule allows port 22 from your IP (not all IPs)
- Check your current public IP: `curl ifconfig.me`

**Website not loading:**
- Check NSG allows port 80 from `*`
- Run `systemctl status nginx` on the VM

---

## Cleanup

```bash
az group delete --name nginx-vm-rg --yes --no-wait
```

> ⚠️ This deletes the entire resource group including VM, VNet, NSG, Public IP.

---

## Production Notes

> **1. Use Azure Application Gateway or Azure Front Door for HTTPS**
> Add TLS termination and SSL certificate at the load balancer level.

> **2. Add Azure Bastion for Secure SSH (no public port 22)**
> Azure Bastion provides browser-based SSH without exposing port 22 publicly.

> **3. Use Azure VM Scale Sets for HA**
> Replace single VM with VM Scale Set across Availability Zones.

> **4. Attach Azure Managed Disk for persistent data**
> OS disk is ephemeral by default. Attach a Premium SSD data disk for application data.

---

## Key Learnings

- Azure VM creation (image reference, hardware profile, OS profile)
- Bicep template language (resources, params, outputs, loadFileAsBase64)
- Azure NSG rules (priority, protocol, direction, source/destination)
- Custom Script Extension (automatic post-deployment script execution)
- SSH key-based authentication on Azure Linux VMs
- Azure Static Public IP with DNS label (FQDN)
- Azure VNet and subnet design (address prefixes)
- `az deployment group create` (Bicep/ARM deployment)
- Azure VM Standard_B1s (burstable — cost-effective for low-traffic workloads)
- NSG SSH restriction to specific IP (security best practice)
