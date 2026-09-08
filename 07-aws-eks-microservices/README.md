# Project 07 - AWS EKS Microservices with Ingress, HPA and Namespace Isolation

## Problem Statement

Your company is migrating a monolithic application to microservices on Kubernetes. Requirements:
- Separate frontend and backend services
- Single external entry point via Ingress
- Automatic pod scaling based on CPU (HPA)
- Namespace isolation for microservices
- Path-based routing (/  → frontend, /api → backend)
- Zero-downtime rolling deployments

Deploy a 2-service microservices architecture on Amazon EKS.

---

## Architecture

```
Internet
  │
  ▼ HTTP
NGINX Ingress Controller (LoadBalancer service)
  │
  ├── / path     → frontend-service (ClusterIP) → Frontend pods (nginx)
  └── /api path  → backend-api-service (ClusterIP) → Backend pods (httpbin)

All resources in namespace: microservices

HPA (autoscaling/v2):
  frontend-hpa  : 2–10 replicas, CPU > 70%
  backend-hpa   : 2–10 replicas, CPU > 70%
```

---

## Project Structure

```
07-aws-eks-microservices/
├── terraform/          ← (reuse EKS from Project 15 or use existing cluster)
└── kubernetes/
    ├── namespace.yaml
    ├── frontend-deployment.yaml  ← RollingUpdate, resources, liveness/readiness probes
    ├── backend-deployment.yaml   ← RollingUpdate, resources, liveness/readiness probes
    ├── services.yaml             ← ClusterIP services for frontend and backend
    ├── ingress.yaml              ← Path-based routing via nginx ingress
    └── hpa.yaml                  ← HPA for both deployments (CPU 70%)
```

---

## Prerequisites

| Tool | Install |
|------|---------|
| AWS CLI | [aws.amazon.com](https://aws.amazon.com/cli/) |
| kubectl | [kubernetes.io](https://kubernetes.io/docs/tasks/tools/) |
| Helm | [helm.sh](https://helm.sh/docs/intro/install/) |
| Existing EKS cluster | See Project 15 (terraform-eks) |

---

## Step 1 — Configure kubectl for EKS

```bash
aws eks update-kubeconfig --region ap-south-1 --name devops-cluster
kubectl get nodes
```

Expected:

```
NAME                                      STATUS   ROLES    AGE
ip-10-0-3-xx.ap-south-1.compute.internal   Ready    <none>   5m
```

---

## Step 2 — Install NGINX Ingress Controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.replicaCount=2
```

Get the Ingress Controller external IP:

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

Expected (wait 2–3 min for EXTERNAL-IP):

```
NAME                       TYPE           EXTERNAL-IP
ingress-nginx-controller   LoadBalancer   13.234.xx.xx
```

---

## Step 3 — Install Metrics Server (required for HPA)

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify
kubectl top nodes
```

---

## Step 4 — Deploy Microservices

```bash
cd kubernetes/

# Create namespace
kubectl apply -f namespace.yaml

# Deploy applications
kubectl apply -f frontend-deployment.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f services.yaml
kubectl apply -f ingress.yaml
kubectl apply -f hpa.yaml
```

---

## Step 5 — Verify All Resources

```bash
kubectl get all -n microservices
```

Expected:

```
NAME                                READY   STATUS    RESTARTS
pod/frontend-xxxx                   1/1     Running   0
pod/frontend-yyyy                   1/1     Running   0
pod/backend-api-xxxx               1/1     Running   0
pod/backend-api-yyyy               1/1     Running   0

NAME                        TYPE        CLUSTER-IP
service/frontend-service    ClusterIP   10.100.x.x
service/backend-api-service ClusterIP   10.100.x.y

NAME                            READY   UP-TO-DATE
deployment.apps/frontend        2/2     2
deployment.apps/backend-api     2/2     2

NAME                                      REFERENCE        TARGETS   MINPODS   MAXPODS
horizontalpodautoscaler/frontend-hpa      Deployment/...   2%/70%    2         10
horizontalpodautoscaler/backend-hpa       Deployment/...   2%/70%    2         10
```

---

## Step 6 — Test Path-Based Routing

```bash
INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test frontend
curl "http://$INGRESS_IP/"

# Test backend API
curl "http://$INGRESS_IP/api/get"
```

---

## Step 7 — Test HPA Scaling

```bash
# Generate CPU load on frontend
kubectl run load-test --image=busybox -n microservices \
  --rm -it --restart=Never -- \
  sh -c "while true; do wget -q -O- http://frontend-service/; done"

# In another terminal, watch HPA scale up
kubectl get hpa -n microservices -w
```

---

## Verification Checklist

✅ NGINX Ingress Controller running with external IP

✅ Metrics Server running (`kubectl top nodes` works)

✅ Frontend pods: 2/2 Running

✅ Backend pods: 2/2 Running

✅ Ingress routing: / → frontend, /api → backend

✅ HPA deployed: TARGETS shows CPU%/70%

✅ RollingUpdate strategy on both deployments

✅ Resource requests and limits set on all containers

---

## Troubleshooting

**HPA shows `<unknown>` for TARGETS:**
- Metrics Server not installed. Run the apply command in Step 3.
- Wait 2–3 minutes for metrics to populate after installation.

**Ingress returns 404:**
- Verify ingress.class annotation matches installed ingress controller
- Check `kubectl describe ingress microservices-ingress -n microservices`

**Pods stuck in `Pending`:**
- Check node capacity: `kubectl describe nodes | grep -A5 "Allocated resources"`
- Reduce resource `requests` in deployment YAML if cluster is small

---

## Cleanup

```bash
kubectl delete namespace microservices
helm uninstall ingress-nginx -n ingress-nginx
kubectl delete namespace ingress-nginx
```

---

## Key Learnings

- Kubernetes namespace isolation (separate namespace per workload)
- Path-based Ingress routing with NGINX controller
- ClusterIP services (internal only — no direct external access)
- Horizontal Pod Autoscaler (autoscaling/v2, CPU TargetUtilization)
- Metrics Server (required for HPA to function)
- Resource requests vs limits (scheduling vs throttling)
- Separate liveness and readiness probes (availability vs traffic readiness)
- RollingUpdate strategy (maxSurge=1, maxUnavailable=0 — zero-downtime)
- Helm (ingress-nginx chart installation)
- EKS kubeconfig configuration (`aws eks update-kubeconfig`)
