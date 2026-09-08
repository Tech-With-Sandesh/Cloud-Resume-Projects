# Resume Points — Project 15: Azure AKS Kubernetes

---

## Fresher

- Deployed a managed Azure Kubernetes Service (AKS) cluster using Terraform with Cluster Autoscaler (1-5 nodes), zone-redundant node pool across 2 availability zones, and Container Insights via OMS agent add-on.
- Integrated Azure Container Registry (ACR) with AKS via AcrPull role assignment on the kubelet's managed identity — pods pull images without requiring imagePullSecrets or credential management.
- Used `az acr build` for cloud-side Docker builds — no local Docker daemon required, images are built and pushed directly from source code in ACR's managed build environment.
- Configured Azure Monitor Container Insights (OMS agent) connected to Log Analytics Workspace for pod-level CPU, memory, and log visibility.

---

## Experienced Cloud Engineer

- Architected a production AKS cluster: SystemAssigned managed identity, Azure CNI networking, Standard Load Balancer, zone-redundant VirtualMachineScaleSets node pool (zones 1+2), Cluster Autoscaler (1-5 nodes), Container Insights (OMS add-on → Log Analytics, 30-day retention) — all in Terraform.
- Implemented AKS-ACR credential-free integration: AcrPull RBAC role assigned to AKS kubelet identity object ID on ACR scope — eliminates long-lived registry credentials in Kubernetes secrets, rotated automatically via managed identity.
- Applied Kubernetes production patterns on AKS: RollingUpdate (maxSurge=1, maxUnavailable=0), resource requests/limits, liveness/readiness probes, Azure LB health probe annotation on Service.
- Documented AKS private cluster, Azure Policy add-on (OPA Gatekeeper), Workload Identity (pod-level managed identity), and KEDA (event-driven autoscaling) as production extensions.

---

## LinkedIn Project Description

Deployed a production AKS cluster using Terraform — zone-redundant node pool (zones 1+2, Cluster Autoscaler 1-5 nodes), ACR (Standard SKU, AcrPull role on kubelet managed identity — no imagePullSecrets), Container Insights via OMS add-on (Log Analytics 30-day retention), Azure CNI, Standard LB. Kubernetes: RollingUpdate, resource limits, liveness/readiness probes, Azure LB Service. `az acr build` for cloud-native Docker builds.

---

## GitHub Project Description

Azure AKS + ACR (Terraform) — AKS (SystemAssigned identity, Azure CNI, Standard LB, zone-redundant VMSS, Cluster Autoscaler), ACR (AcrPull role on kubelet identity), Container Insights (Log Analytics). Kubernetes: RollingUpdate, probes, LB service.

---

## How to Explain in an Interview (30 Seconds)

"I deployed an AKS cluster using Terraform with two key production features. First, Cluster Autoscaler — the node pool uses VirtualMachineScaleSets and scales from 1 to 5 nodes automatically based on pending pods. Second, ACR integration without credentials — instead of creating an imagePullSecret with registry username and password in every namespace, I assigned the AcrPull RBAC role to the AKS kubelet's managed identity. This means AKS uses its system-assigned managed identity to authenticate with ACR, so there are no static credentials to manage or rotate."

---

## Skills Demonstrated

- Azure Kubernetes Service (managed control plane, VMSS node pool)
- Cluster Autoscaler (min/max nodes, pending pod trigger)
- Zone-redundant AKS nodes (high availability across AZs)
- Azure Container Registry (Standard, admin disabled)
- AcrPull role assignment (credential-free image pulls)
- SystemAssigned Managed Identity (AKS, kubelet identity)
- Azure Monitor Container Insights (OMS agent add-on)
- Log Analytics Workspace (PerGB2018, retention)
- Azure CNI networking (pod IP from VNet subnet)
- az acr build (cloud-native Docker build)
- Kubernetes RollingUpdate + probes + resource limits
