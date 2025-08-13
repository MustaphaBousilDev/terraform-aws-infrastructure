# 🏗️ AWS Infrastructure Automation with Terraform

[![Terraform](https://img.shields.io/badge/Terraform-1.0%2B-623CE4?logo=terraform&logoColor=white)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Infrastructure](https://img.shields.io/badge/Infrastructure-as%20Code-blueviolet)](https://terraform.io)

A production-ready, enterprise-grade AWS infrastructure platform built with Terraform. This project demonstrates modern Infrastructure as Code practices with modular architecture, security best practices, and scalable design patterns.

## 🚀 **Project Overview**

This project creates a complete, secure, and scalable AWS infrastructure using Terraform modules. It implements a 5-tier architecture suitable for hosting modern web applications with enterprise-level security and operational requirements.

### **Key Features**

- ✅ **Modular Architecture** - Reusable Terraform modules for maximum flexibility
- ✅ **Multi-Environment Support** - Consistent deployments across dev, staging, and production
- ✅ **Enterprise Security** - KMS encryption, Secrets Manager, IAM best practices
- ✅ **High Availability** - Multi-AZ deployment with auto-scaling capabilities
- ✅ **Cost Optimized** - Right-sized resources with automatic scaling
- ✅ **Production Ready** - Monitoring-ready, backup-enabled, secure by default

## 🏗️ **Architecture Overview**

```
┌─────────────────────────────────────────────────────────────────┐
│                           Internet                              │
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────┐
│                 Application Load Balancer                       │
│                    (Public Subnets)                             │
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────┐
│               Auto Scaling Group (EC2)                          │
│                  (Private Subnets)                              │
└─────────────────────────┬───────────────────────────────────────┘
                          │
    ┌─────────────────────┼─────────────────────┐
    │                     │                     │
    ▼                     ▼                     ▼
┌─────────┐        ┌─────────────┐        ┌─────────────┐
│   RDS   │        │ S3 Buckets  │        │   Security  │
│ MySQL   │        │ (App/Static │        │ (KMS/IAM/   │
│Database │        │  /Logs)     │        │ Secrets)    │
└─────────┘        └─────────────┘        └─────────────┘
```

### **Infrastructure Components**

| Module | Purpose | AWS Services | Features |
|--------|---------|--------------|----------|
| **Networking** | Network foundation | VPC, Subnets, IGW, NAT | Multi-AZ, Public/Private subnets |
| **Security** | Identity & encryption | IAM, KMS, Secrets Manager | Least privilege, encryption at rest |
| **Compute** | Application hosting | ALB, ASG, EC2 | Auto-scaling, load balancing |
| **Database** | Data persistence | RDS MySQL | Multi-AZ, automated backups |
| **Storage** | File & object storage | S3 | Versioning, lifecycle policies |

## 📋 **Prerequisites**

### **Required Tools**
- [Terraform](https://terraform.io/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) >= 2.0
- [Git](https://git-scm.com/) for version control

### **AWS Requirements**
- AWS Account with appropriate permissions
- AWS CLI configured with access keys
- Permissions for: VPC, EC2, RDS, S3, IAM, KMS, Secrets Manager

### **Local Setup**
```bash
# Verify installations
terraform --version  # Should be >= 1.0
aws --version        # Should be >= 2.0
aws sts get-caller-identity  # Verify AWS access
```

## 🚀 **Quick Start**

### **1. Clone Repository**
```bash
git clone https://github.com/MustaphaBousilDev/terraform-aws-infrastructure.git
cd terraform-aws-infrastructure
```

### **2. Bootstrap Infrastructure (One-time setup)**
```bash
cd bootstrap
terraform init
terraform apply -var="project_name=your-project-name"
```

**⚠️ Important:** Save the `backend_config_template` output for step 3.

### **3. Configure Dev Environment**
```bash
cd ../environments/dev
```

Create `backend.tf` with the output from step 2:
```hcl
terraform {
  backend "s3" {
    bucket         = "your-project-terraform-state-xxxxx"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "your-project-terraform-locks"
    encrypt        = true
  }
}
```

### **4. Deploy Infrastructure**
```bash
terraform init
terraform plan
terraform apply
```

### **5. Access Your Infrastructure**
```bash
terraform output load_balancer_url
# Visit the URL to see your deployed application
```

## 📁 **Project Structure**

```
terraform-aws-infrastructure/
├── 📁 bootstrap/                    # S3 backend setup (run once)
│   ├── main.tf                      # S3 + DynamoDB for remote state
│   ├── variables.tf                 # Bootstrap configuration
│   └── outputs.tf                   # Backend connection details
│
├── 📁 environments/                 # Environment-specific deployments
│   └── 📁 dev/                      # Development environment
│       ├── main.tf                  # Module orchestration
│       ├── variables.tf             # Environment variables
│       ├── terraform.tfvars         # Variable values
│       ├── backend.tf               # S3 backend configuration
│       └── outputs.tf               # Environment outputs
│
├── 📁 modules/                      # Reusable infrastructure modules
│   ├── 📁 networking/               # VPC, subnets, security groups
│   ├── 📁 security/                 # IAM, KMS, Secrets Manager
│   ├── 📁 compute/                  # ALB, ASG, EC2 instances
│   ├── 📁 database/                 # RDS configuration
│   └── 📁 storage/                  # S3 bucket management
│
├── .gitignore                       # Git ignore rules
└── README.md                        # This file
```

## 🔧 **Configuration**

### **Environment Variables**
Customize your deployment by editing `environments/dev/terraform.tfvars`:

```hcl
# Project Configuration
project_name = "my-awesome-app"
environment  = "dev"
aws_region   = "us-east-1"

# Networking
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# Compute
instance_type = "t3.micro"

# Security
create_ssl_certificate = false  # Set to true for HTTPS
domain_name           = ""       # Your domain for SSL
```

### **Security Configuration**
The project includes several security features:

- **Encryption at Rest:** All data encrypted using KMS
- **Secrets Management:** Database passwords stored in AWS Secrets Manager
- **Network Security:** Private subnets, security groups with minimal access
- **IAM Roles:** Least privilege access for all components
- **SSL/TLS Ready:** Optional HTTPS with AWS Certificate Manager

## 🌍 **Multi-Environment Deployment**

### **Create Additional Environments**
```bash
# Copy dev environment
cp -r environments/dev environments/staging
cp -r environments/dev environments/prod

# Update terraform.tfvars for each environment
cd environments/staging
# Edit terraform.tfvars: change environment = "staging"

cd ../prod  
# Edit terraform.tfvars: change environment = "prod"
```

### **Deploy Each Environment**
```bash
# Staging
cd environments/staging
terraform init
terraform apply

# Production
cd environments/prod
terraform init
terraform apply
```

## 📊 **Module Documentation**

### **Networking Module**
Creates the foundational network infrastructure:
- **VPC:** Isolated network environment
- **Subnets:** Public (2) and Private (2) across multiple AZs
- **Gateways:** Internet Gateway and NAT Gateway for connectivity
- **Security:** Network ACLs and Security Groups

**Usage:**
```hcl
module "networking" {
  source = "../../modules/networking"
  
  project_name       = "my-app"
  environment        = "dev"
  vpc_cidr          = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
}
```

### **Security Module**
Implements enterprise security practices:
- **KMS:** Customer-managed encryption keys
- **Secrets Manager:** Secure storage for sensitive data
- **IAM:** Roles and policies following least privilege
- **SSL/TLS:** Optional certificate management

**Usage:**
```hcl
module "security" {
  source = "../../modules/security"
  
  project_name           = "my-app"
  environment            = "dev"
  db_password            = "SecurePassword123!"
  create_ssl_certificate = false
}
```

### **Compute Module**
Provides scalable application hosting:
- **Load Balancer:** Application Load Balancer with health checks
- **Auto Scaling:** Automatic capacity management
- **Security Groups:** Network-level security controls

**Usage:**
```hcl
module "compute" {
  source = "../../modules/compute"
  
  project_name       = "my-app"
  environment        = "dev"
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  instance_type      = "t3.micro"
}
```

### **Database Module**
Manages relational database infrastructure:
- **RDS MySQL:** Managed database service
- **Security:** Database subnet groups and security groups
- **Backup:** Automated backups and maintenance windows

**Usage:**
```hcl
module "database" {
  source = "../../modules/database"
  
  project_name          = "my-app"
  environment           = "dev"
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  app_security_group_id = module.compute.app_security_group_id
  db_password           = "SecurePassword123!"
}
```

### **Storage Module**
Handles object storage requirements:
- **Application Storage:** User uploads and dynamic content
- **Static Assets:** Website files and media
- **Logs:** Application and access logs with lifecycle management

**Usage:**
```hcl
module "storage" {
  source = "../../modules/storage"
  
  project_name      = "my-app"
  environment       = "dev"
  enable_versioning = true
  enable_public_read = false
}
```

## 🔧 **Management Commands**

### **Common Operations**
```bash
# View current infrastructure
terraform show

# Check for configuration drift
terraform plan

# Apply only specific modules
terraform apply -target=module.networking

# View all outputs
terraform output

# Refresh state from AWS
terraform refresh

# Validate configuration
terraform validate
```

### **Cleanup**
```bash
# Destroy specific environment
cd environments/dev
terraform destroy

# Destroy bootstrap (WARNING: This removes state storage)
cd bootstrap
terraform destroy -var="project_name=your-project-name"
```

## 🔍 **Troubleshooting**

### **Common Issues**

**Issue:** `Error: Backend configuration changed`
```bash
# Solution: Re-initialize backend
terraform init -reconfigure
```

**Issue:** `Error: Instance cannot be destroyed (lifecycle protect)`
```bash
# Solution: Remove lifecycle protection in code, then apply
lifecycle {
  # prevent_destroy = true  # Comment this out
}
```

**Issue:** `Error: InvalidUserID.NotFound`
```bash
# Solution: Check AWS credentials and permissions
aws sts get-caller-identity
```

**Issue:** Resource name too long (32 character limit)
```bash
# Solution: Shorten project_name in terraform.tfvars
project_name = "shorter-name"
```

### **Debug Mode**
```bash
# Enable detailed logging
export TF_LOG=DEBUG
terraform apply

# Log to file
export TF_LOG_PATH=./terraform.log
```

## 💰 **Cost Optimization**

### **Development Environment**
- Use `t3.micro` instances (free tier eligible)
- Set up billing alerts
- Destroy resources when not in use

### **Production Environment**
- Use Reserved Instances for predictable workloads
- Enable S3 Intelligent Tiering
- Set up CloudWatch billing alarms
- Use Spot Instances for non-critical workloads

### **Daily Cost-Saving Routine**
```bash
# End of development day
terraform destroy

# Start of development day
terraform apply
```

## 🔐 **Security Best Practices**

### **Implemented Security Measures**
- ✅ **Encryption at Rest:** KMS encryption for all data stores
- ✅ **Encryption in Transit:** HTTPS/SSL ready configuration
- ✅ **Network Isolation:** Private subnets for sensitive resources
- ✅ **Access Control:** IAM roles with minimal permissions
- ✅ **Secrets Management:** No hardcoded credentials
- ✅ **Audit Trail:** CloudTrail integration ready

### **Additional Recommendations**
- Enable AWS CloudTrail for audit logging
- Set up AWS Config for compliance monitoring
- Use AWS Systems Manager Session Manager instead of SSH
- Implement rotation policies for secrets
- Regular security reviews and updates

## 📈 **Monitoring & Observability**

### **Built-in Features**
- CloudWatch integration ready
- Load balancer health checks
- RDS monitoring and alerts
- S3 access logging capability

### **Recommended Additions**
- Application Performance Monitoring (APM)
- Log aggregation with ELK stack
- Custom CloudWatch dashboards
- SNS notifications for critical alerts

## 🤝 **Contributing**

### **Development Workflow**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Test changes in isolated environment
4. Commit changes (`git commit -m 'Add amazing feature'`)
5. Push to branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### **Code Standards**
- Follow Terraform best practices
- Include module documentation
- Test with `terraform validate` and `terraform plan`
- Update README for significant changes

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ **Support & Contact**

- **Issues:** [GitHub Issues](https://github.com/yourusername/terraform-aws-infrastructure/issues)
- **Documentation:** [Project Wiki](https://github.com/yourusername/terraform-aws-infrastructure/wiki)
- **Email:** your.email@example.com

## 🏷️ **Tags**

`terraform` `aws` `infrastructure-as-code` `devops` `cloud` `automation` `vpc` `ec2` `rds` `s3` `security` `scalability` `production-ready` `enterprise`

---

## 📊 **Project Statistics**

- **AWS Services:** 15+ integrated services
- **Terraform Modules:** 5 reusable modules
- **Infrastructure Resources:** 50+ AWS resources
- **Environments Supported:** Development, Staging, Production
- **Security Features:** KMS, IAM, Secrets Manager, SSL/TLS ready
- **High Availability:** Multi-AZ deployment across 2 availability zones

**⭐ Star this repository if it helped you build better infrastructure!**
