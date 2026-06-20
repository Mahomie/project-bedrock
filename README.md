# Project Bedrock — InnovateMart EKS Deployment

## Architecture
- **VPC:** project-bedrock-vpc (10.0.0.0/16) — 2 public + 2 private subnets across us-east-1a and us-east-1b
- **EKS:** project-bedrock-cluster (v1.34) — managed node group (t3.medium x2) in private subnets
- **Data Layer:** RDS MySQL (catalog), RDS PostgreSQL (orders), DynamoDB (carts)
- **Ingress:** AWS Load Balancer Controller + ALB (internet-facing)
- **Observability:** CloudWatch Observability EKS Add-on (FluentBit + CloudWatch Agent)
- **Serverless:** S3 (bedrock-assets-alt-soe-025-4722) → Lambda (bedrock-asset-processor)
- **CI/CD:** GitHub Actions (plan on PR, apply on merge to main)

## Application URL
http://k8s-retailap-retailst-17d19cf248-733961238.us-east-1.elb.amazonaws.com

## How to Trigger the Pipeline

### Plan (Pull Request)
1. Create a new branch: `git checkout -b feature/my-change`
2. Make changes to any file under `terraform/`
3. Push and open a Pull Request to `main`
4. GitHub Actions will run `terraform plan` and post the output as a PR comment

### Apply (Merge to Main)
1. Merge the Pull Request to `main`
2. GitHub Actions will automatically run `terraform apply`

## Deploy Application (Helm)
```bash
aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster
helm upgrade --install retail-store \
  oci://public.ecr.aws/aws-containers/retail-store-sample-chart \
  --version 0.8.5 \
  -n retail-app \
  -f k8s/app/values.yaml \
  --timeout 10m \
  --wait
```


## Application Version Note
This deployment uses the official AWS `retail-store-sample-chart` umbrella Helm chart (v0.8.5 — the latest available version of the single-command umbrella chart on Amazon ECR Public), with a custom `values.yaml` overriding the in-cluster databases to use managed AWS services (RDS MySQL, RDS PostgreSQL, DynamoDB). The chart is sourced from the official `aws-containers` organization.

Note on versioning: AWS's newer 1.x releases (e.g. 1.6.1) are published only as separate per-service charts (`retail-store-sample-ui-chart`, `-catalog-chart`, etc.), deployed one service at a time. The combined umbrella chart that enables a single `helm upgrade --install` deployment is versioned 0.8.x, with 0.8.5 being the latest. The umbrella chart was deliberately chosen to satisfy the single-command Helm deployment (bonus objective 5.1).

## Grading Credentials
- **IAM User:** bedrock-dev-view
- **Access Key ID:** (provided separately in submission document)
- **Console URL:** https://425221105441.signin.aws.amazon.com/console

## Terraform Outputs
Run `terraform output` in the `terraform/` directory to see all outputs.
Generated `grading.json` is committed to the repo root.

## Resource Tagging
All resources tagged: `Project: karatu-2025-capstone`

## Bonus: HTTPS / TLS (Objective 5.2)
- Custom DNS via nip.io: `https://3.214.58.99.nip.io`
- TLS terminated at the ALB using an ACM certificate
- HTTP (port 80) automatically redirects to HTTPS (port 443)
- Note: certificate is self-signed (no owned domain), so browsers show a trust warning. TLS itself works and the certificate is managed in AWS Certificate Manager.

## Bonus: Helm Deployment (Objective 5.1)
The application is deployed via the upstream Helm chart with a custom values.yaml overriding the data layer to use RDS and DynamoDB:

    helm upgrade --install retail-store \
      oci://public.ecr.aws/aws-containers/retail-store-sample-chart \
      --version 0.8.5 -n retail-app \
      -f k8s/app/values.yaml --timeout 10m --wait
