# Resume Points — Project 20: Azure VNet Peering Hub-Spoke

---

## Fresher

- Designed a hub-spoke Azure VNet architecture using Terraform: Hub VNet (10.1.0.0/16), Spoke1 App VNet (10.2.0.0/16), Spoke2 DB VNet (10.3.0.0/16) with bidirectional VNet peering between Hub and each spoke.
- Configured VNet peering with `allow_forwarded_traffic = true` on hub connections enabling transit routing — Spoke1 reaches Spoke2 via Hub without a direct peering link between spokes.
- Applied NSG on DB subnet restricting port 1433 to source CIDR 10.2.1.0/24 (app subnet) only, with explicit DenyAll rule at priority 4096.
- VNet peering is non-transitive by design — without Azure Firewall or NVA in Hub for east-west routing, direct spoke-to-spoke communication is blocked even with hub peering.

---

## Experienced Cloud Engineer

- Architected an Azure Hub-Spoke network: 3 VNets (non-overlapping CIDRs: 10.1/10.2/10.3 /16), 4 peering resources (2 per pair — each direction), `allow_forwarded_traffic = true` on all connections, DB subnet NSG with CIDR-based port 1433 allow + priority 4096 DenyAll catch-all.
- Implemented NSG subnet association on DB subnet — NSG rules allow MySQL/SQL Server (1433) only from app subnet CIDR, DenyAll blocks all other inbound traffic including direct internet access to the database tier.
- Explained VNet peering non-transitivity: Spoke1 and Spoke2 are not directly peered — for production east-west inspection, Azure Firewall should be deployed in Hub with UDRs forcing all inter-spoke traffic through the firewall.
- Documented Azure Firewall + UDR (User Defined Routes) for centralised east-west traffic inspection, VPN Gateway for hybrid connectivity, and Private DNS Zone attachment to Hub VNet.

---

## LinkedIn Project Description

Designed an Azure Hub-Spoke VNet architecture using Terraform — Hub (10.1.0.0/16) peered with Spoke1-App (10.2.0.0/16) and Spoke2-DB (10.3.0.0/16) via 4 bidirectional peering connections (allow_forwarded_traffic=true). DB subnet NSG: Allow 1433 from app subnet CIDR, DenyAll priority 4096. Non-transitive peering design with Azure Firewall + UDR documented as production east-west inspection path.

---

## How to Explain in an Interview (30 Seconds)

"I built a hub-spoke VNet architecture on Azure. The key concept is that VNet peering is non-transitive — Spoke1 and Spoke2 are not directly connected to each other. All traffic between them flows through the Hub, which is where you'd put an Azure Firewall for inspection. I configured `allow_forwarded_traffic = true` on the hub peering connections so traffic can transit through. For the DB subnet, I attached an NSG that only allows port 1433 from the app subnet's CIDR — 10.2.1.0/24 — and has a DenyAll rule at the lowest priority as a catch-all."

---

## Skills Demonstrated

- Azure VNet Peering (bidirectional resources, peering state)
- Hub-Spoke network topology (centralised connectivity)
- allow_forwarded_traffic (transit routing through hub)
- VNet peering non-transitivity (design implication)
- NSG priority ordering (Allow before DenyAll catch-all)
- NSG subnet association (subnet-level enforcement)
- VNet CIDR design (non-overlapping: 10.1/10.2/10.3)
- Azure Firewall + UDR (production east-west inspection)
- VPN Gateway (hybrid on-premises connectivity)
- Private DNS Zone (centralised name resolution in hub)
