# Resume Points — Project 07: AWS EKS Microservices

---

## Fresher

- Deployed a 2-service microservices architecture on Amazon EKS with namespace isolation, NGINX Ingress path-based routing (/ → frontend, /api → backend), and Horizontal Pod Autoscaler (CPU 70%, 2-10 replicas).
- Configured Kubernetes Deployments with RollingUpdate strategy (maxSurge=1, maxUnavailable=0) for zero-downtime deployments and separate liveness/readiness probes per service.
- Set resource requests and limits on all containers enabling Kubernetes scheduler bin-packing and HPA metric collection via Metrics Server.
- Installed NGINX Ingress Controller via Helm and Metrics Server for HPA CPU-based autoscaling.

---

## Experienced Cloud Engineer

- Designed a Kubernetes microservices platform on EKS: NGINX Ingress (path-based routing) → ClusterIP services (internal only) → Deployments (RollingUpdate, 0 downtime) → HPA (autoscaling/v2, CPU TargetUtilization 70%) — with namespace isolation separating microservices from system workloads.
- Implemented HPA with autoscaling/v2 API — CPU TargetUtilization 70% triggers scale-out to maximum 10 replicas; scale-in stabilisation window prevents pod flapping during traffic oscillation.
- Configured separate liveness (`/` path, 30s interval) and readiness (`/` path, 10s interval) probes per deployment — liveness restarts crashed containers, readiness gates traffic routing to only healthy pods.
- Documented cluster-level auto scaling (Cluster Autoscaler for EKS node group) and KEDA (event-driven autoscaling) as production scaling extensions beyond CPU-based HPA.

---

## LinkedIn Project Description

Deployed a microservices architecture on Amazon EKS — NGINX Ingress Controller (path-based routing: / → frontend, /api → backend), ClusterIP services, autoscaling/v2 HPA (CPU 70%, 2-10 replicas per service), RollingUpdate deployments (maxSurge=1, maxUnavailable=0), resource requests/limits, separate liveness/readiness probes, Metrics Server for HPA. Namespace isolation for all microservices resources.

---

## GitHub Project Description

AWS EKS Microservices — Namespace isolation, NGINX Ingress (path routing), ClusterIP services, RollingUpdate Deployments (liveness/readiness probes, resource limits), autoscaling/v2 HPA (CPU 70%, 2-10 replicas). Helm: ingress-nginx. Metrics Server for HPA.

---

## How to Explain in an Interview (30 Seconds)

"I deployed a microservices setup on EKS with a frontend and backend service. All traffic comes in through the NGINX Ingress Controller — it routes based on the URL path, so / goes to the frontend and /api goes to the backend. Both services are ClusterIP, meaning they have no external access directly — only the Ingress can route to them. I added HPA with the autoscaling/v2 API set to CPU target 70%, so each service scales from 2 to 10 pods automatically. Each deployment has separate liveness and readiness probes — liveness detects if a container is hung and restarts it, readiness controls whether traffic is sent to a pod during startup."

---

## Skills Demonstrated

- Amazon EKS (cluster, kubeconfig, node groups)
- Kubernetes Namespaces (workload isolation)
- NGINX Ingress Controller (path-based routing, Helm installation)
- Kubernetes Services (ClusterIP — internal routing only)
- Horizontal Pod Autoscaler (autoscaling/v2, CPU TargetUtilization)
- Metrics Server (HPA dependency for CPU metrics)
- RollingUpdate Strategy (maxSurge, maxUnavailable, zero-downtime)
- Liveness vs Readiness Probes (restart vs traffic gating)
- Resource Requests and Limits (scheduling and throttling)
- Helm (package management for Kubernetes)
- kubectl (apply, get, describe, top, logs)
