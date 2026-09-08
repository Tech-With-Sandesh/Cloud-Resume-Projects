# Resume Points — Project 21: Azure Container Registry

---

## Fresher

- Set up Azure Container Registry (Standard SKU, admin disabled) and used `az acr build` for cloud-native Docker builds — no local Docker daemon required, Dockerfile is sent to ACR's managed build environment.
- Configured User-Assigned Managed Identity with AcrPull role on ACR, allowing Azure Container Instances to pull images without registry credentials or image pull secrets.
- Deployed containerised application on Azure Container Instances with liveness HTTP probe, public DNS label (FQDN), and environment variable injection.
- Enabled 30-day image retention policy to automatically clean up untagged images and prevent registry storage bloat.

---

## Experienced Cloud Engineer

- Designed credential-free ACR → ACI image pull: User-Assigned Managed Identity (separate from System-Assigned for portability) → AcrPull role on ACR scope → `image_registry_credential` with `user_assigned_identity_id` in ACI — no username/password in infrastructure code.
- Applied ACR Standard SKU with retention policy (30-day auto-delete for untagged manifests), admin disabled (service principal/managed identity only), and Defender for Containers vulnerability scanning on push.
- Used `az acr build` for supply chain security — image is built in Azure's trusted environment directly from source code, not on a developer's potentially compromised local machine.
- Documented ACR Geo-replication (Premium SKU, multi-region image mirroring), ACR Tasks (scheduled rebuilds, base image update triggers), and Private Endpoint for ACR as production patterns.

---

## LinkedIn Project Description

Deployed Azure Container Registry (Standard SKU, admin disabled, retention 30d) with cloud-native builds (`az acr build` — no local Docker) and credential-free ACI pull via User-Assigned Managed Identity (AcrPull role). Flask app deployed on Azure Container Instances (0.5vCPU, liveness probe, public FQDN). Defender for Containers vulnerability scanning on push. Terraform: ACR, identity, role assignment, ACI.

---

## How to Explain in an Interview (30 Seconds)

"I set up Azure Container Registry and used az acr build to build images directly in the cloud. This is more secure than building locally because the build happens in Azure's trusted environment, not on my machine. For pulling images from ACI, instead of enabling admin credentials — which is a static username and password — I used a User-Assigned Managed Identity with the AcrPull role on the ACR. The container instance authenticates using its managed identity, so there are zero static credentials anywhere."

---

## Skills Demonstrated

- Azure Container Registry (Standard SKU, retention policy, admin disabled)
- az acr build (cloud-native Docker build, supply chain security)
- User-Assigned Managed Identity (portability across resources)
- AcrPull role assignment (least-privilege image pull)
- Azure Container Instances (serverless containers, DNS label, liveness probe)
- image_registry_credential with managed identity (credential-free)
- ACR vulnerability scanning (Defender for Containers)
- Retention policy (untagged image cleanup)
- ACR Geo-replication (Premium SKU, multi-region)
- ACR Tasks (base image update triggers, scheduled builds)
