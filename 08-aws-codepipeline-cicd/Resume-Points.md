# Resume Points — Project 08: AWS CodePipeline CI/CD

---

## Fresher

- Built a 3-stage AWS CodePipeline (Source → Build → Deploy) using Terraform — GitHub push to `main` triggers the pipeline via CodeStar Connection, CodeBuild runs tests and builds Docker images, ECS Fargate is updated automatically.
- Wrote a CodeBuild `buildspec.yml` with 4 phases: install dependencies, run pytest unit tests, docker build + push to ECR, generate `imagedefinitions.json` artifact for ECS deployment.
- Configured CodeBuild with `privileged_mode = true` and Git SHA image tagging (`CODEBUILD_RESOLVED_SOURCE_VERSION`) for reproducible, traceable Docker images.
- Stored Docker Hub credentials in AWS SSM Parameter Store as SecureString and referenced them in buildspec via `parameter-store` block — no credentials in source code.

---

## Experienced Cloud Engineer

- Designed a fully AWS-native CI/CD pipeline: CodeStar Connection (GitHub webhook) → CodePipeline (3 stages, S3 artifact bucket with versioning) → CodeBuild (pytest gate → docker build → ECR push) → ECS deploy via `imagedefinitions.json` contract — zero Jenkins or self-managed build servers.
- Implemented `imagedefinitions.json` artifact pattern (CodePipeline's ECS deployment contract): CodeBuild writes `[{"name":"container","imageUri":"ecr-url:git-sha"}]` — CodePipeline reads this and creates a new ECS task definition revision with the exact image SHA, ensuring immutable deployment traceability.
- Applied least-privilege IAM: CodeBuild role scoped to specific ECR repo ARN + S3 artifact bucket ARN + SSM path prefix; CodePipeline role scoped to CodeBuild project ARN and ECS actions.
- Documented approval stage addition between Build and Deploy for production gating, and CodeBuild report groups for test result visualisation.

---

## LinkedIn Project Description

Built a fully managed CI/CD pipeline using AWS-native services: CodePipeline (3 stages) + CodeBuild (buildspec.yml: pytest → docker build → ECR push) + ECS Fargate (rolling deploy via imagedefinitions.json). GitHub integration via CodeStar Connection. Git SHA image tagging, SSM SecureString for secrets, privileged CodeBuild for Docker. Least-privilege IAM for CodeBuild and CodePipeline. Deployed with Terraform.

---

## GitHub Project Description

AWS CodePipeline CI/CD — CodePipeline (Source→Build→Deploy) + CodeBuild (buildspec.yml: pytest gate + ECR push + imagedefinitions.json) + ECS Fargate rolling deploy. CodeStar GitHub connection, Git SHA tagging, SSM secrets, privileged_mode. Terraform: CodePipeline, CodeBuild, ECR, S3 artifacts, IAM.

---

## How to Explain in an Interview (30 Seconds)

"I built a CI/CD pipeline using AWS-native services — no Jenkins. When I push to the main branch, CodeStar Connection triggers CodePipeline. The Build stage runs CodeBuild, which executes my buildspec: it installs dependencies, runs pytest, and if tests pass, builds the Docker image tagged with the git commit SHA and pushes to ECR. Then it writes an imagedefinitions.json file that tells CodePipeline which container name maps to which ECR image URI. In the Deploy stage, CodePipeline reads that file and creates a new ECS task definition revision with the exact image SHA, then does a rolling deployment on the ECS service."

---

## Skills Demonstrated

- AWS CodePipeline (3-stage pipeline, S3 artifact store, stage connections)
- AWS CodeBuild (buildspec.yml phases, privileged mode, Docker builds)
- CodeStar Connections (GitHub OAuth, pending → available activation)
- imagedefinitions.json (ECS deployment artifact contract)
- ECR image tagging (Git SHA — immutable, traceable deployments)
- AWS SSM Parameter Store (SecureString for secrets in buildspec)
- ECS rolling deployment via CodePipeline
- IAM least-privilege (scoped CodeBuild and CodePipeline roles)
- CodeBuild pip cache (faster CI builds)
- S3 artifact bucket with versioning (pipeline stage data exchange)
