# 🏗️ Terraform AWS Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-1.0%2B-623CE4?logo=terraform)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

Modern, scalable AWS infrastructure automation using Terraform with reusable modules and multi-environment support.

## 🚀 Features

- ✅ **Modular Architecture** - Reusable Terraform modules
- ✅ **Multi-Environment** - Dev, Staging, Production environments
- ✅ **Best Practices** - Security, scalability, and cost optimization
- ✅ **CI/CD Ready** - GitHub Actions integration
- ✅ **State Management** - Remote state with S3 + DynamoDB
- ✅ **Auto-Scaling** - Dynamic infrastructure scaling
- ✅ **Monitoring** - CloudWatch, logging, and alerting
- ✅ **Security** - VPC, IAM, Security Groups, SSL/TLS

## 📋 Prerequisites

- [Terraform](https://terraform.io/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) >= 2.0
- AWS Account with appropriate permissions
- [Git](https://git-scm.com/) for version control

## 🛠️ Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/MustaphaBousilDev/terraform-aws-infrastructure.git
cd terraform-aws-infrastructure
```

### 2. Configure AWS Credentials
```bash
aws configure
# or export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
```

### 3. Initialize Backend (First Time Only)
```bash
cd terraform/bootstrap
terraform init
terraform apply
```

### 4. Deploy Environment
```bash
cd ../environments/dev
terraform init
terraform plan
terraform apply
```

## 📁 Project Structure

```
terraform/
├── 📁 bootstrap/              # S3 backend and DynamoDB setup
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── 📁 environments/           # Environment-specific configurations
│   ├── 📁 dev/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── variables.tf
│   ├── 📁 staging/
│   └── 📁 prod/
├── 📁 modules/                # Reusable Terraform modules
│   ├── 📁 networking/         # VPC, subnets, security groups
│   ├── 📁 compute/            # EC2, ECS, Lambda
│   ├── 📁 database/           # RDS, DynamoDB
│   ├── 📁 storage/            # S3, EFS
│   ├── 📁 security/           # IAM, KMS, WAF
│   ├── 📁 monitoring/         # CloudWatch, SNS
│   └── 📁 load-balancer/      # ALB, NLB
├── 📁 scripts/                # Helper scripts
├── 📁 docs/                   # Documentation
└── README.md
```

## 🏗️ Available Modules

### Core Infrastructure
| Module | Description | Resources |
|--------|-------------|-----------|
| `networking` | VPC, Subnets, Route Tables | VPC, IGW, NAT Gateway, Route Tables |
| `security` | Security Groups, IAM Roles | Security Groups, IAM, NACL |
| `compute` | EC2, ECS, Auto Scaling | EC2, ECS Cluster, Launch Templates |
| `database` | RDS, DynamoDB | RDS Instance, Parameter Groups |
| `storage` | S3 Buckets, EFS | S3, EFS, Lifecycle Policies |
| `load-balancer` | Application Load Balancer | ALB, Target Groups, Listeners |
| `monitoring` | CloudWatch, Alarms | CloudWatch, SNS, Dashboards |

### Application Modules
| Module | Description | Use Case |
|--------|-------------|----------|
| `web-app` | Web application hosting | React, Angular, Vue.js apps |
| `api-server` | API backend infrastructure | REST APIs, GraphQL |
| `database-cluster` | High-availability database | Production databases |
| `cdn` | CloudFront distribution | Global content delivery |

## 🌍 Environment Management

### Development Environment
```bash
cd environments/dev
terraform workspace select dev || terraform workspace new dev
terraform apply -var-file="terraform.tfvars"
```

### Staging Environment
```bash
cd environments/staging
terraform workspace select staging || terraform workspace new staging
terraform apply -var-file="terraform.tfvars"
```

### Production Environment
```bash
cd environments/prod
terraform workspace select prod || terraform workspace new prod
terraform apply -var-file="terraform.tfvars"
```

## 📊 Usage Examples

### Basic Web Application Stack
```hcl
module "networking" {
  source = "../../modules/networking"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = "10.0.0.0/16"
}

module "web_app" {
  source = "../../modules/web-app"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
  subnet_ids   = module.networking.private_subnet_ids
}
```

### Database with Backup
```hcl
module "database" {
  source = "../../modules/database"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
  subnet_ids   = module.networking.database_subnet_ids
  
  engine_version    = "14.9"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  backup_retention  = 7
}
```

## 🔧 Configuration

### Environment Variables
```bash
# Required
export AWS_REGION="us-west-2"
export TF_VAR_project_name="my-project"
export TF_VAR_environment="dev"

# Optional
export TF_VAR_enable_monitoring="true"
export TF_VAR_enable_backup="true"
```

### Terraform Variables
```hcl
# terraform.tfvars
project_name = "my-awesome-project"
environment  = "dev"
region      = "us-west-2"

# Networking
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-west-2a", "us-west-2b"]

# Compute
instance_type = "t3.micro"
min_size     = 1
max_size     = 3

# Database
db_instance_class = "db.t3.micro"
db_storage_size  = 20
```

## 🔐 Security Best Practices

- ✅ **Encrypted Storage** - All data encrypted at rest
- ✅ **VPC Isolation** - Private subnets for sensitive resources
- ✅ **IAM Least Privilege** - Minimal required permissions
- ✅ **Security Groups** - Restrictive inbound/outbound rules
- ✅ **SSL/TLS** - HTTPS enforcement
- ✅ **Secrets Management** - AWS Secrets Manager integration
- ✅ **Resource Tagging** - Consistent tagging strategy

## 💰 Cost Optimization

- ✅ **Right-Sizing** - Appropriate instance types
- ✅ **Auto-Scaling** - Scale based on demand
- ✅ **Spot Instances** - For non-critical workloads
- ✅ **Reserved Instances** - For predictable workloads
- ✅ **Storage Lifecycle** - Automated data archiving
- ✅ **Resource Scheduling** - Start/stop non-prod resources

## 📈 Monitoring & Alerting

### CloudWatch Dashboards
- Infrastructure health metrics
- Application performance monitoring
- Cost and billing alerts
- Security event monitoring

### Automated Alerts
```hcl
# High CPU utilization
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  threshold           = "80"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
name: Terraform Deploy
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - name: Terraform Init
        run: terraform init
      - name: Terraform Plan
        run: terraform plan
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
```

## 🚀 Getting Started Checklist

- [ ] Clone repository
- [ ] Configure AWS credentials
- [ ] Review and customize `terraform.tfvars`
- [ ] Initialize Terraform backend
- [ ] Deploy development environment
- [ ] Test infrastructure components
- [ ] Set up monitoring and alerts
- [ ] Configure CI/CD pipeline
- [ ] Deploy to staging/production

## 📚 Documentation

- [Module Documentation](docs/modules/)
- [Best Practices Guide](docs/best-practices.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Contributing Guidelines](CONTRIBUTING.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

- 📧 Email: bousilmustapha@gmail.com

## 🏷️ Tags

`terraform` `aws` `infrastructure` `devops` `iac` `automation` `cloud` `cicd` `monitoring` `security`

---

**⭐ Star this repository if it helped you!**
