# Project 15 - Azure Kubernetes Service (AKS) with ACR, Container Insights and Cluster Autoscaler

## Problem Statement

Your team needs a managed Kubernetes cluster on Azure with:
- No Kubernetes control plane management (managed by Azure)
- Private container registry integrated with AKS (no credentials in pods)
- Automatic node scaling based on pod demand (Cluster Autoscaler)
- Container-level monitoring via Azure Monitor Container Insights
- Zone-redundant node pool for high availability

Deploy a production AKS cluster using Terraform with ACR integration.

---

## Architecture

```
Developer → docker push → Azure Container Registry (ACR)
                                    │ (AcrPull role — no credentials needed)
                                    ▼
                         AKS Cluster (Managed Control Plane)
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
               Node (Zone 1)  Node (Zone 2)  [Auto-scaled Nodes]
               (Standard_D2s_v3 — Cluster Autoscaler: 1-5 nodes)
                                    │
               Container Insights → Log Analytics Workspace
```

---

## Project Structure

```
15-azure-aks-kubernetes/
├── terraform/
│   ├── main.tf       ← AKS, ACR, Log Analytics, AcrPull role assignment
│   ├── variables.tf
│   └── outputs.tf
└── kubernetes/
    ├── deployment.yaml   ← RollingUpdate, resources, probes
    └── service.yaml      ← LoadBalancer service (Azure LB)
```

---

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | ≥ 1.3.0 |
| Azure CLI | ≥ 2.50 |
| kubectl | ≥ 1.29 |
| Docker | ≥ 24.0 |

---

## Step 1 — Login and Initialize

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"

cd terraform/
terraform init
terraform plan
terraform apply
```

> ⚠️ AKS provisioning takes 5–10 minutes.

---

## Step 2 — Configure kubectl

```bash
$(terraform output -raw kubeconfig_command)
kubectl get nodes
```

Expected:

```
NAME                              STATUS   ROLES   AGE
aks-system-00000000-vmss000000    Ready    agent   5m
aks-system-00000000-vmss000001    Ready    agent   5m
```

---

## Step 3 — Build and Push Image to ACR

```bash
ACR=$(terraform output -raw acr_login_server)

az acr build \
  --registry "$(terraform output -raw acr_login_server | cut -d. -f1)" \
  --image web-app:latest \
  --file Dockerfile .
```

> ℹ️ `az acr build` builds directly in ACR — no local Docker daemon needed.

---

## Step 4 — Update and Deploy Kubernetes Manifests

```bash
# Replace ACR URL in deployment.yaml
ACR=$(terraform output -raw acr_login_server)
sed -i "s|YOUR_ACR.azurecr.io|$ACR|g" kubernetes/deployment.yaml

kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
```

Wait for pods and external IP:

```bash
kubectl get pods -w
kubectl get svc web-app-service -w
```

---

## Step 5 — Test the Application

```bash
EXTERNAL_IP=$(kubectl get svc web-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl "http://$EXTERNAL_IP"
```

---

## Step 6 — View Container Insights

1. Azure Portal → **AKS Cluster** → **Insights**
2. View pod-level CPU, memory, and log data
3. Filter by namespace, deployment, or pod

---

## Verification Checklist

✅ AKS cluster in `Succeeded` state

✅ 2 nodes `Ready` across 2 availability zones

✅ ACR created and AcrPull role assigned to AKS kubelet identity

✅ Image pushed to ACR and pods pulling without image pull secrets

✅ Pods `Running` (2/2)

✅ LoadBalancer service has external IP

✅ Application accessible at `http://EXTERNAL_IP`

✅ Container Insights showing metrics in Azure Portal

✅ Cluster Autoscaler configured (min 1, max 5 nodes)

---

## Troubleshooting

**`ImagePullBackOff` — image pull fails:**
- Verify AcrPull role assignment: `az role assignment list --scope $(terraform output -raw acr_id)`
- Wait 2–3 minutes after role assignment for propagation

**Nodes stuck in `Not Ready`:**
- Check node pool: `az aks nodepool list --cluster-name <name> --resource-group <rg>`
- Check quota: `az vm list-usage --location eastus --query "[?contains(name.value,'cores')]"`

---

## Cleanup

```bash
kubectl delete -f kubernetes/
cd terraform/ && terraform destroy
```

---

## Key Learnings

- Azure Kubernetes Service (managed control plane, kubelet identity)
- Azure Container Registry (Standard SKU, admin disabled, AcrPull integration)
- AKS + ACR integration via role assignment (no imagePullSecrets needed)
- SystemAssigned managed identity for AKS
- Cluster Autoscaler (`enable_auto_scaling`, min/max counts)
- Zone-redundant node pool (`zones = ["1","2"]`)
- Azure Monitor Container Insights (OMS agent add-on)
- Log Analytics Workspace (PerGB2018 SKU, retention)
- `az acr build` (cloud build — no local Docker required)
- Azure Load Balancer provisioned by `type: LoadBalancer` Kubernetes service
