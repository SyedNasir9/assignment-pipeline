# Event-Driven Data Processing Pipeline

[![AWS](https://img.shields.io/badge/AWS-S3%20%7C%20ECS%20%7C%20ECR-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/Terraform-Infrastructure-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)

A production-ready, event-driven batch processing pipeline that reliably ingests raw data, processes it on schedule, and produces structured output artifacts for downstream consumers.

## 🎯 Core Objectives

- **Decoupling** — Producers and consumers operate independently
- **Durability** — Reliable storage with retry and replay capabilities
- **Automation** — Infrastructure as Code for repeatability
- **Observability** — Comprehensive logging and monitoring
- **Security** — Least-privilege IAM and encryption at rest
- **Cost-Efficient** — Serverless architecture that scales with demand

## 🏗️ Architecture

```
Data Sources → S3 (Raw Data) → EventBridge (Scheduler) → ECS Fargate (Processing) → S3 (Reports)
                    ↓                                            ↓
                Versioning                                CloudWatch Logs
```

### Components

| Component | Purpose | Technology |
|-----------|---------|------------|
| **Storage** | Durable data lake for raw inputs and reports | Amazon S3 |
| **Orchestration** | Schedule-based or event-driven triggers | EventBridge |
| **Compute** | Containerized processing runtime | ECS Fargate |
| **Registry** | Container image storage | Amazon ECR |
| **Infrastructure** | Codified resource provisioning | Terraform |
| **CI/CD** | Automated build and deployment | GitHub Actions |
| **Monitoring** | Logging and observability | CloudWatch |

## 🚀 Data Flow

1. **Ingestion** — Raw files uploaded to `s3://bucket/raw-data/YYYY-MM-DD/`
2. **Trigger** — EventBridge invokes ECS task on schedule or event
3. **Processing** — Fargate container reads data, aggregates results
4. **Output** — Report written to `s3://bucket/reports/YYYY-MM-DD.json`
5. **Logging** — All operations logged to CloudWatch for audit and debugging

## 📋 Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- Docker
- Python 3.11+
- GitHub repository for CI/CD

## 🛠️ Setup

### 1. Infrastructure Provisioning

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. CI/CD Configuration

Configure GitHub Secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

### 3. Deploy Application

Push to main branch to trigger automated build and deployment:

```bash
git push origin main
```

## 🔐 Security Features

- **IAM Roles** — Separate execution and task roles with least-privilege policies
- **Encryption** — S3 server-side encryption (SSE-S3)
- **Network Isolation** — VPC configuration with security groups
- **Image Scanning** — ECR vulnerability scanning on push
- **Secrets Management** — AWS Secrets Manager integration

## 📊 Monitoring & Observability

### CloudWatch Integration
- Container logs: `/ecs/assignment`
- Metrics: Task success/failure rates, duration, record counts
- Alarms: Task failures, processing delays

### Recommended Alarms
- Task stopped with non-zero exit code
- No reports generated for 24+ hours
- Processing duration exceeds threshold

## 🔧 Operations

### Manual Task Execution

```bash
aws ecs run-task \
  --cluster <cluster-name> \
  --task-definition <task-def> \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[<subnet-id>],securityGroups=[<sg-id>]}" \
  --overrides '{"containerOverrides":[{"name":"processor","environment":[{"name":"RUN_DATE","value":"2025-01-15"}]}]}'
```

### Reprocessing Data

Set `RUN_DATE` environment variable to reprocess specific dates:

```bash
RUN_DATE=2025-01-15 ./scripts/reprocess.sh
```

## 📈 Scaling Patterns

| Pattern | Use Case | Implementation |
|---------|----------|----------------|
| **Vertical** | Larger files | Increase Fargate CPU/memory |
| **Horizontal** | High volume | Partition data, run parallel tasks |
| **Fan-out** | Complex workflows | SQS queue + worker fleet |

## 💰 Cost Optimization

- S3 lifecycle policies for data retention
- Fargate task sizing matched to workload
- ECR image cleanup policies
- CloudWatch log retention policies
- Scheduled tasks run during off-peak hours

## 🧪 Testing

```bash
# Unit tests
pytest tests/unit/

# Integration tests (requires localstack)
pytest tests/integration/

# End-to-end tests (dev environment)
./scripts/e2e-test.sh
```

## 🔄 CI/CD Pipeline

1. **Build** — Docker image built on code push
2. **Scan** — Image scanned for vulnerabilities
3. **Push** — Image pushed to ECR with commit SHA tag
4. **Deploy** — Task definition updated (manual trigger)

## 📚 Project Structure

```
.
├── terraform/           # Infrastructure as Code
├── src/                 # Application code
├── .github/workflows/   # CI/CD pipelines
├── tests/               # Test suites
└── scripts/             # Operational scripts
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Task fails to start | Check IAM execution role, ECR permissions |
| Permission denied on S3 | Verify task role has `s3:GetObject`, `s3:PutObject` |
| No logs in CloudWatch | Ensure task execution role has CloudWatch permissions |
| Image pull errors | Verify ECR repository policy, check image exists |

## 🚦 Production Readiness Checklist

- [ ] Remote Terraform state with locking (S3 + DynamoDB)
- [ ] Multi-environment setup (dev/staging/prod)
- [ ] Automated testing in CI pipeline
- [ ] Comprehensive monitoring and alerting
- [ ] Disaster recovery and backup procedures
- [ ] Secrets managed via AWS Secrets Manager
- [ ] VPC endpoints for private S3/ECR access
- [ ] Blue-green deployment strategy


---

**Built with ❤️ using AWS serverless technologies**
