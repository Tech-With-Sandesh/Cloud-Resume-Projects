# Project 23 - GCP GKE Kubernetes Cluster with VPC-Native Networking, Workload Identity and Cluster Autoscaler

## Problem Statement

Your team needs a managed Kubernetes cluster on Google Cloud with:
- Managed control plane (no etcd management)
- VPC-native networking (pods get real VPC IPs — no IP masquerade)
- Cluster Autoscaler (nodes scale with workload)
- Workload Identity (pods use GCP IAM — no Service Account keys)
- Auto-repair and auto-upgrade for node pools
- REGULAR release channel for managed Kubernetes upgrades

---

## Architecture

```
GKE Cluster (REGULAR release channel, Workload Identity)
  │
  ├── VPC Network (custom, auto_create_subnetworks=false)
  │   └── Subnet: 10.0.0.0/24
  │       ├── Pods CIDR:     10.1.0.0/16  (secondary range)
  │       └── Services CIDR: 10.2.0.0/20  (secondary range)
  │
  └── Node Pool (e2-medium, auto-repair, auto-upgrade)
      Cluster Autoscaler: 1-5 nodes
      Workload Identity: GKE_METADATA mode

Deployment → LoadBalancer Service → Google Cloud Load Balancer → Internet
```

---

## Project Structure

```
23-gcp-gke-kubernetes/
├── terraform/
│   ├── main.tf       ← VPC, GKE cluster, node pool (autoscaling, Workload Identity)
│   ├── variables.tf
│   └── outputs.tf
└── kubernetes/
    ├── deployment.yaml
    └── service.yaml
```

---

## Prerequisites

| Tool | Install |
|------|---------|
| Terraform | ≥ 1.3.0 |
| gcloud CLI | [cloud.google.com/sdk](https://cloud.google.com/sdk/docs/install) |
| kubectl | [kubernetes.io](https://kubernetes.io/docs/tasks/tools/) |
| GCP Project | [console.cloud.google.com](https://console.cloud.google.com) |

---

## Step 1 — Configure gcloud

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud services enable container.googleapis.com compute.googleapis.com
```

---

## Step 2 — Deploy GKE Cluster

```bash
cd terraform/
terraform init
terraform apply -var="project_id=YOUR_PROJECT_ID"
```

> ⚠️ GKE cluster creation takes 5–8 minutes.

---

## Step 3 — Configure kubectl

```bash
$(terraform output -raw get_credentials)
kubectl get nodes
```

Expected:

```
NAME                                     STATUS   ROLES    AGE
gke-cloud-gke-node-pool-xxxxx-0          Ready    <none>   5m
gke-cloud-gke-node-pool-xxxxx-1          Ready    <none>   5m
```

---

## Step 4 — Deploy Application

```bash
cd ../kubernetes/
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Wait for external IP
kubectl get svc web-app-service -w
```

---

## Step 5 — Test Application

```bash
EXTERNAL_IP=$(kubectl get svc web-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl "http://$EXTERNAL_IP"
```

---

## Step 6 — Test Cluster Autoscaler

```bash
# Scale deployment to exceed node capacity
kubectl scale deployment web-app --replicas=20

# Watch nodes scale up automatically
kubectl get nodes -w
```

---

## Verification Checklist

✅ VPC with custom subnet and secondary ranges (pods/services)

✅ GKE cluster created (REGULAR channel, Workload Identity enabled)

✅ Node pool: auto-repair=true, auto-upgrade=true

✅ Cluster Autoscaler: 1-5 nodes

✅ `kubectl get nodes` shows 2 nodes `Ready`

✅ Deployment: 2/2 pods Running

✅ LoadBalancer service has external IP

✅ Application accessible at `http://EXTERNAL_IP`

---

## Troubleshooting

**`Error: googleapi: Error 403: Required API not enabled`:**
- Run: `gcloud services enable container.googleapis.com`

**Pods stuck `Pending` — `Insufficient cpu`:**
- Cluster Autoscaler should add nodes within 2–3 minutes
- Check: `kubectl describe pod <pod-name>`

**External IP `<pending>`:**
- Wait 2–3 minutes for GCP to provision the load balancer
- Check: `kubectl describe svc web-app-service`

---

## Cleanup

```bash
cd kubernetes/
kubectl delete -f .

cd ../terraform/
terraform destroy -var="project_id=YOUR_PROJECT_ID"
```

> ⚠️ GKE clusters cost approximately $0.10/hour for the cluster fee + node costs.

---

## Key Learnings

- GKE managed Kubernetes (remove_default_node_pool=true pattern)
- VPC-native networking (ip_allocation_policy with secondary ranges)
- Workload Identity (GKE_METADATA mode — no Service Account key files)
- REGULAR release channel (managed Kubernetes version upgrades)
- Cluster Autoscaler (autoscaling block in node pool)
- auto_repair + auto_upgrade (self-healing, patched node pools)
- Secondary IP ranges (pods: /16, services: /20 — GKE IP planning)
- deletion_protection = false (allow terraform destroy)
- GKE LoadBalancer service → Google Cloud TCP Load Balancer
- `gcloud container clusters get-credentials` (kubeconfig configuration)
