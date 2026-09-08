# Resume Points — Project 16: Azure DevOps CI/CD Pipeline

---

## Fresher

- Built a 3-stage Azure Pipelines YAML CI/CD pipeline (Build+Test → Push ACR → Deploy AKS) triggered automatically on push to the `main` branch.
- Configured Docker@2 pipeline task to build and push Docker images to Azure Container Registry using `$(Build.BuildId)` for unique, traceable image tagging per pipeline run.
- Used KubernetesManifest@1 task to deploy Kubernetes manifests to AKS with automatic image tag substitution — replacing the `latest` tag in YAML with the build-specific tag.
- Added PublishTestResults@2 task with `condition: always()` to publish pytest JUnit results to the Pipeline Tests tab even when tests fail.

---

## Experienced Cloud Engineer

- Designed a 3-stage Azure Pipelines CI/CD workflow: `dependsOn` chain (Build → Push → Deploy) with `condition: succeeded()` ensuring deployment only proceeds after passing tests and successful ACR push — fail-fast pipeline design.
- Implemented `environment: production` deployment job with approval gate — pipeline pauses before production deployment until designated approvers approve, creating a manual governance checkpoint without pipeline code changes.
- Configured Azure service connections (Docker Registry → ACR, Azure Resource Manager → subscription) as the authentication bridge between Azure Pipelines and Azure resources — no credentials in pipeline YAML.
- Documented Azure Pipelines library variable groups (link Azure Key Vault secrets to pipeline variables), multi-stage environments with deployment strategies (blue/green, canary), and YAML templates for pipeline reuse.

---

## LinkedIn Project Description

Built a 3-stage Azure Pipelines YAML CI/CD pipeline — Build+Test (pytest → PublishTestResults), Push (Docker@2 → ACR with BuildId tag), Deploy (KubernetesManifest@1 → AKS production namespace with image substitution). Environment approval gates for production gating. Azure service connections for ACR and ARM. Fail-fast design with dependsOn + condition: succeeded().

---

## How to Explain in an Interview (30 Seconds)

"I built a 3-stage Azure Pipelines YAML pipeline. The Build stage runs pytest and publishes test results — I use condition: always() so results are captured even if tests fail. Only if tests pass does it move to Push, which builds and pushes the Docker image to ACR tagged with the build ID. The Deploy stage uses KubernetesManifest task which automatically substitutes the image tag in my Kubernetes YAML files with the new build-specific tag and applies them to AKS. I also added an environment approval gate so production deployments require manual sign-off from a team lead before proceeding."

---

## Skills Demonstrated

- Azure Pipelines YAML (stages, jobs, steps, dependsOn, conditions)
- Docker@2 task (build + push with registry service connection)
- KubernetesManifest@1 (AKS deployment with image substitution)
- PublishTestResults@2 (JUnit, condition: always())
- Azure service connections (ACR, Azure Resource Manager)
- Environment approval gates (production gating)
- $(Build.BuildId) image tagging (immutable, traceable)
- Fail-fast pipeline design (dependsOn + condition: succeeded())
- Azure Pipelines environments (production namespace)
- Azure Key Vault variable groups (secrets in pipelines)
