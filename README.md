# StreamSphere (Go + React + AWS, ECS Fargate) 

**Region:** configurable via `infra/terraform.tfvars` (default: `us-west-1`)  
**Prefix:** `streamsphere` (used for resource names)  

## What this includes
- Go REST API (ECS Fargate) + Go Worker (SQS consumer)
- React SPA (S3 + CloudFront)
- Terraform for VPC, ECS, ALB, Aurora Serverless (PostgreSQL), S3, CloudFront, Redis, SQS, Cognito, IAM, CloudWatch
- GitHub Actions CI/CD (build & push to ECR, Terraform apply)
- Diagrams (`.drawio` and PNG placeholders)

> Note: For a classroom demo, this repository is designed to stand up **core infrastructure** out of the box.  
> Some optional components (WAF/X-Ray) are scaffolded for clarity and can be enabled later.

---

## Quick start

### 0) Prereqs
- AWS CLI configured with an account that has permissions
- Terraform ≥ 1.6
- Docker ≥ 24
- Node ≥ 18 (for frontend)
- (Optional) GitHub repo to use CI/CD with OIDC

### 1) Build & push Docker images (manually the first time)
```bash
# API
cd app/api
docker build -t streamsphere-api:latest .
aws ecr create-repository --repository-name streamsphere-api || true
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(jq -r .region infra/terraform.tfvars 2>/dev/null || echo "us-west-1")
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
docker tag streamsphere-api:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/streamsphere-api:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/streamsphere-api:latest

# Worker
cd ../worker
docker build -t streamsphere-worker:latest .
aws ecr create-repository --repository-name streamsphere-worker || true
docker tag streamsphere-worker:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/streamsphere-worker:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/streamsphere-worker:latest
```

### 2) Terraform apply
```bash
cd ../../infra
terraform init
terraform apply -auto-approve
```

Outputs will print: ALB DNS, CloudFront URL, Cognito IDs, and S3 buckets.

### 3) Frontend build & deploy
```bash
cd ../app/frontend
npm ci
npm run build
# Replace <frontend-bucket> with the output from Terraform
aws s3 sync dist/ s3://<frontend-bucket> --delete
```

### 4) Test
- Open CloudFront URL (frontend)
- Sign up via Cognito Hosted UI, then upload a small video
- Watch video playback (served via CloudFront from S3)

## Repo Structure
```
streamsphere/
├── infra/ (Terraform IaC)
├── app/
│   ├── api/ (Go API)
│   ├── worker/ (Go worker)
│   └── frontend/ (React SPA)
├── diagrams/ (*.drawio + .png)
└── .github/workflows/deploy.yml (CI/CD)
```

]
