# Resume Points — Project 13: Azure VM with Nginx

---

## Fresher

- Provisioned an Azure Ubuntu 22.04 VM using Bicep IaC — VNet, NSG (SSH restricted to specific IP, HTTP/HTTPS open), Static Public IP with DNS label, and NIC — fully automated.
- Used Azure Custom Script Extension to automatically install and configure Nginx and deploy a website after VM provisioning, eliminating manual SSH configuration steps.
- Configured SSH key-based authentication (RSA 4096-bit) with password authentication disabled — following Azure security best practices for Linux VMs.
- Restricted SSH (port 22) in NSG to a specific `/32` IP CIDR — preventing internet-wide brute force attacks.

---

## Experienced Cloud Engineer

- Designed an Azure VM deployment in Bicep: VNet (10.0.0.0/16), NSG (priority-ordered rules: HTTP 100, HTTPS 110, SSH to /32 CIDR 120), Standard SKU Static Public IP with DNS label, Custom Script Extension executing post-provisioning shell script via `loadFileAsBase64`.
- Implemented Custom Script Extension pattern — base64-encoded shell script in Bicep template executes Nginx installation and website deployment atomically during VM provisioning, creating a fully configured server on first boot.
- Documented Azure Bastion (browser-based SSH without public port 22), Application Gateway (HTTPS/WAF), and VM Scale Sets with Availability Zones as production upgrade paths.
- Applied Standard SKU Public IP (required for Zone-redundant deployments and Azure Front Door) over Basic SKU.

---

## LinkedIn Project Description

Deployed an Azure Ubuntu 22.04 VM using Bicep IaC — VNet, NSG (SSH restricted to /32 IP), Static Standard Public IP, Custom Script Extension (auto-installs Nginx + deploys website on boot), SSH key-based auth (password auth disabled). Documented Azure Bastion, Application Gateway HTTPS, and VM Scale Sets as production patterns.

---

## GitHub Project Description

Azure VM + Nginx (Bicep) — VNet, NSG (IP-restricted SSH), Static Public IP, Custom Script Extension (base64 script), SSH key auth. Production: Bastion, Application Gateway, VM Scale Sets, Availability Zones.

---

## How to Explain in an Interview (30 Seconds)

"I deployed an Azure VM using Bicep and configured it completely with a Custom Script Extension. The extension takes my shell script, base64 encodes it directly in the Bicep template, and Azure runs it automatically after the VM boots. The script installs Nginx, enables it as a service, and deploys the website — so by the time provisioning finishes, the server is fully configured. The NSG restricts SSH to only my specific IP address, and the public IP is Standard SKU with a static allocation and DNS label."

---

## Skills Demonstrated

- Azure Virtual Machines (Ubuntu 22.04, B1s, disk types)
- Azure Bicep (resources, params, outputs, loadFileAsBase64)
- Azure NSG (priority-ordered inbound rules, IP restriction)
- Custom Script Extension (post-provisioning automation)
- Azure VNet and Subnets (address space design)
- Azure Public IP (Standard SKU, static, DNS label)
- SSH key-based authentication (RSA 4096, disabled password auth)
- Azure CLI (`az deployment group create`, `az group create`)
- Azure Bastion (secure SSH without public port — production path)
- Azure Application Gateway (HTTPS, WAF — production path)
- Azure VM Scale Sets (HA horizontal scaling)
