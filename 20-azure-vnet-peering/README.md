# Project 20 - Azure VNet Peering: Hub-Spoke Network Architecture

## Problem Statement

Your organisation needs a hub-spoke network architecture where:
- A central Hub VNet connects shared services
- Spoke VNets host app and DB tiers in isolation
- App VNet can reach DB VNet only via Hub (no direct spoke-to-spoke)
- DB subnet NSG restricts access to port 1433 from app subnet only

---

## Architecture

```
Hub VNet (10.1.0.0/16)
  ├── Hub ↔ Spoke1 (bidirectional peering, forwarded traffic)
  └── Hub ↔ Spoke2 (bidirectional peering, forwarded traffic)

Spoke1 VNet — App (10.2.0.0/16)
  └── app-subnet: 10.2.1.0/24

Spoke2 VNet — DB (10.3.0.0/16)
  └── db-subnet: 10.3.1.0/24
      └── NSG: Allow port 1433 from 10.2.1.0/24 only
               DenyAll (priority 4096)

Note: Spoke1 and Spoke2 are NOT peered to each other.
Traffic flows: Spoke1 → Hub → Spoke2 (hub-and-spoke routing)
```

---

## Project Structure

```
20-azure-vnet-peering/
└── terraform/
    ├── main.tf      ← 3 VNets, 4 peering connections, DB NSG with rules
    ├── variables.tf
    └── outputs.tf
```

---

## Step 1 — Deploy

```bash
az group create --name vnet-peering-rg --location eastus

cd terraform/
terraform init && terraform apply
```

---

## Step 2 — Verify Peering Status

```bash
az network vnet peering list \
  --resource-group vnet-peering-rg \
  --vnet-name hub-vnet \
  --query "[].{Name:name, State:peeringState}" \
  --output table
```

Expected:

```
Name           State
-------------  ---------
hub-to-spoke1  Connected
hub-to-spoke2  Connected
```

---

## Step 3 — Test Connectivity

Deploy a VM in Spoke1 (app subnet) and Spoke2 (db subnet), then test:

```bash
# From Spoke1 VM — ping Spoke2 VM (should work via Hub)
ping 10.3.1.4

# From internet — cannot reach db subnet (no public IP, NSG blocks)
```

---

## Verification Checklist

✅ Hub VNet: 10.1.0.0/16

✅ Spoke1 (App) VNet: 10.2.0.0/16

✅ Spoke2 (DB) VNet: 10.3.0.0/16

✅ Hub ↔ Spoke1 peering: Connected (both directions)

✅ Hub ↔ Spoke2 peering: Connected (both directions)

✅ DB NSG: Allow 1433 from 10.2.1.0/24, DenyAll priority 4096

✅ No direct Spoke1 ↔ Spoke2 peering (hub-spoke pattern)

---

## Troubleshooting

**Peering state `Initiated` (not `Connected`):**
- Both directions of peering must be created. Verify `spoke1_to_hub` and `hub_to_spoke1` both exist.

**VM in Spoke1 can't reach Spoke2:**
- Verify `allow_forwarded_traffic = true` on hub peering connections
- Check DB NSG allows source CIDR `10.2.1.0/24` on port 1433

---

## Cleanup

```bash
terraform destroy
az group delete --name vnet-peering-rg --yes
```

---

## Key Learnings

- Azure VNet Peering (bidirectional — two resources per peering pair)
- Hub-Spoke network topology (centralised connectivity, isolated spokes)
- `allow_forwarded_traffic = true` (enable transit routing through hub)
- `allow_gateway_transit` / `use_remote_gateways` (VPN Gateway sharing)
- NSG subnet association (apply NSG to entire subnet)
- DenyAll rule priority 4096 (explicit catch-all deny on DB NSG)
- VNet CIDR non-overlap requirement (10.1/10.2/10.3 — no overlap)
- VNet peering is non-transitive (Spoke1 cannot reach Spoke2 without hub routing)
- Azure Firewall in Hub VNet (centralised east-west traffic inspection — production)
- Private DNS Zone attached to Hub VNet (centralised DNS resolution)
