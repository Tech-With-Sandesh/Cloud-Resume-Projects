# Resume Points — Project 23: GCP GKE Kubernetes

---

## Fresher

- Deployed a GKE cluster on GCP using Terraform with VPC-native networking (secondary IP ranges for pods and services), Cluster Autoscaler (1-5 nodes), and REGULAR release channel for managed Kubernetes upgrades.
- Configured Workload Identity (GKE_METADATA mode) on the node pool — pods can call GCP APIs using GCP IAM without Service Account key files.
- Enabled auto_repair and auto_upgrade on the node pool for self-healing and automatic security patching.
- Used `remove_default_node_pool = true` pattern to separate cluster creation from node pool configuration, enabling independent node pool management.

---

## Experienced Cloud Engineer

- Architected a production GKE cluster: custom VPC (auto_create_subnetworks=false), subnet with secondary ranges (pods: 10.1.0.0/16, services: 10.2.0.0/20), VPC-native ip_allocation_policy, REGULAR release channel, Workload Identity (GKE_METADATA), http_load_balancing and horizontal_pod_autoscaling add-ons enabled.
- Implemented GKE Workload Identity to eliminate Service Account key files: `workload_pool = PROJECT_ID.svc.id.goog` on cluster + `GKE_METADATA` mode on node pool — pods authenticate to GCP APIs via projected service account tokens, not long-lived JSON keys.
- Used VPC-native networking (ip_allocation_policy with cluster/services secondary_ip_range_name) so pods get native VPC IPs — enables VPC firewall rules on pods, VPC peering without IP conflicts, and Cloud Run / on-prem connectivity without NAT.

---

## LinkedIn Project Description

Deployed a GKE cluster using Terraform — VPC-native networking (custom VPC, subnet with secondary ranges for pods/services), REGULAR release channel, Workload Identity (GKE_METADATA, no Service Account keys), Cluster Autoscaler (1-5 e2-medium nodes), auto_repair + auto_upgrade, http_load_balancing + HPA add-ons. Kubernetes: RollingUpdate deployment, LoadBalancer service → GCP TCP Load Balancer.

---

## How to Explain in an Interview (30 Seconds)

"I deployed a GKE cluster using Terraform with VPC-native networking. The key concept here is the secondary IP ranges — the subnet has a separate CIDR for pods and another for services, and the cluster allocates IPs from those ranges. This means pods get real VPC IP addresses, not NAT'd IPs, which enables direct VPC firewall rules on pods and peering with other networks. I also enabled Workload Identity so pods can call GCP APIs using their GCP IAM service account — no JSON key files to manage or rotate."

---

## Skills Demonstrated

- GKE (managed Kubernetes, remove_default_node_pool pattern)
- VPC-native networking (secondary IP ranges, ip_allocation_policy)
- Workload Identity (GKE_METADATA, no Service Account keys)
- REGULAR release channel (managed upgrades)
- Cluster Autoscaler (autoscaling min/max counts)
- auto_repair + auto_upgrade (node self-healing and patching)
- Secondary IP ranges (pod CIDR planning — /16 for pods, /20 for services)
- GKE add-ons (http_load_balancing, horizontal_pod_autoscaling)
- gcloud container clusters get-credentials (kubeconfig)
- GCP TCP Load Balancer via Kubernetes LoadBalancer service
