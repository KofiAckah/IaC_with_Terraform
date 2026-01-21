# Infrastructure as Code with Terraform

A complete AWS infrastructure deployment using Terraform with modular architecture, remote state management, and multi-environment support.

## 📋 Project Overview

This project demonstrates Infrastructure as Code (IaC) best practices by deploying a complete AWS infrastructure including:
- **VPC with public subnets**
- **Security groups with proper firewall rules**
- **EC2 instances running Nginx web servers**
- **Remote state management with S3 and DynamoDB**
- **Multi-environment support (dev, staging, prod)**

## 🏗️ Architecture

The infrastructure is organized into two main components:

### 1. Backend Setup (Bash Scripts)
Automated bash scripts set up the remote state backend before deploying main infrastructure.

- **S3 Backend**: Secure, versioned storage for Terraform state files
- **DynamoDB Table**: State locking to prevent concurrent modifications
- **Logging System**: Comprehensive logging with color-coded output
- **State Management**: Idempotent operations with state tracking

### 2. Main Infrastructure (Terraform)
Modular architecture with three core modules:

#### Network Module
- VPC with DNS support
- Public subnet with internet gateway
- Route tables with internet routing
- Auto-assign public IPs

#### Security Module
- Security groups for application servers
- Ingress rules: HTTP (80), HTTPS (443), SSH (22 from VPC only)
- Egress rules: Allow all outbound traffic

#### Compute Module
- Ubuntu 22.04 EC2 instances
- Automated Nginx installation via user data
- Custom HTML landing page with environment info
- Public IP assignment for web access

## 📁 Project Structure

```
IaC_with_Terraform/
├── scripts/                        # Backend setup bash scripts
│   ├── setup_backend.sh           # Main script to create S3 & DynamoDB
│   ├── config.sh                  # Configuration variables
│   ├── utils.sh                   # Logging and utility functions
│   └── .tfstate.env               # State tracking file (auto-generated)
│
└── infrastructure/                 # Main infrastructure
    ├── main.tf                    # Root module configuration
    ├── provider.tf                # AWS provider settings
    ├── variable.tf                # Input variables
    ├── output.tf                  # Infrastructure outputs
    ├── backend.tf                 # Remote state configuration
    ├── dev.tfvars                 # Development environment variables
    ├── stag.tfvars                # Staging environment variables
    ├── prod.tfvars                # Production environment variables
    └── modules/
        ├── Network/               # VPC and networking resources
        │   ├── main.tf
        │   ├── variable.tf
        │   └── output.tf
        ├── Security/              # Security groups and rules
        │   ├── main.tf
        │   ├── variable.tf
        │   └── output.tf
        └── Compute/               # EC2 instances and web servers
            ├── main.tf
            ├── variable.tf
            └── output.tf
```

## 🚀 Prerequisites

Before you begin, ensure you have the following:

- **Terraform**: Version 1.0 or higher ([Install Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli))
- **AWS CLI**: Configured with valid credentials ([Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- **AWS Account**: With appropriate IAM permissions
- **SSH Key Pair**: Created in your AWS region (for EC2 access)

### Required AWS Permissions

Your IAM user/role needs permissions for:
- EC2 (instances, VPCs, security groups, subnets)
- S3 (bucket creation and management)
- DynamoDB (table creation and management)

## 📝 Deployment Steps

### Step 1: Configure Backend Setup

First, review and customize the backend configuration if needed:

```bash
# Navigate to scripts directory
cd scripts/

# Review configuration (optional - defaults are already set)
cat config.sh

# Default values:
# - PROJECT_NAME="iac-terraform"
# - ENVIRONMENT="dev"
# - AWS_REGION="eu-west-1"
# - BUCKET_NAME="iac-terraform-dev-tfstate"
# - DYNAMODB_TABLE="iac-terraform-dev-tfstate-lock"
```

### Step 2: Run Backend Setup Script

Execute the bash script to create S3 bucket and DynamoDB table:

```bash
# Make script executable (if not already)
chmod +x setup_backend.sh

# Run the backend setup script
./setup_backend.sh
```

The script will:
- ✅ Validate AWS CLI installation and credentials
- ✅ Create S3 bucket with versioning and encryption
- ✅ Block public access to the S3 bucket
- ✅ Create DynamoDB table for state locking
- ✅ Save configuration to `.tfstate.env`
- ✅ Provide backend configuration for Terraform

**Output Example:**
```
==========================================
Backend Setup Summary
==========================================
S3 Bucket: iac-terraform-dev-tfstate
DynamoDB Table: iac-terraform-dev-tfstate-lock
Region: eu-west-1

Add the following to your backend.tf:

terraform {
  backend "s3" {
    bucket         = "iac-terraform-dev-tfstate"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "iac-terraform-dev-tfstate-lock"
    encrypt        = true
  }
}
==========================================
```
5: Deploy Main Infrastructure

```bash
# Navigate to infrastructure directory
cd ../infrastructure/

# Initialize Terraform (configures backend)
terraform init

# Validate configuration
terraform validate

# Preview changes for development environment
terraform plan -var-file="dev.tfvars"

# Deploy the infrastructure
terraform apply -var-file="dev.tfvars"

# When prompted, type 'yes' to confirm
```

### Step 3 Development (`dev.tfvars`):**
```hcl
environment  = "dev"
project_name = "iac-terraform"
owner        = "your-name"
aws_region   = "eu-west-1"
vpc_cidr     = "10.0.0.0/16"
key_name     = "your-key-pair-name"  # Your AWS SSH key pair

common_tags = {
  ManagedBy   = "Terraform"
  Environment = "dev"
  CostCenter  = "Development"
  Department  = "Engineering"
}
```

### Step 4: Deploy Main Infrastructure

```bash
# Navigate to infrastructure directory
cd ../infrastructure/

# Initialize Terraform (configures backend)
terraform init

# Validate configuration
terraform validate

# Preview changes for development environment
terraform plan -var-file="dev.tfvars"

# Deploy the infrastructure
terraform apply -var-file="dev.tfvars"

# When prompted, type 'yes' to confirm
```

### Step 5: Access Your Application

After successful deployment, Terraform will output the website URL:

```bash
# Output example:
website_url = "http://54.123.45.67"
instance_public_ip = "54.123.45.67"
```

Open the `website_url` in your browser to see your deployed web application!

**Note**: Wait 2-3 minutes after deployment for the user data script to complete Nginx installation.

## 🌍 Multi-Environment Deployment

Deploy to different environments using the respective `.tfvars` files:

```bash
# Development
terraform apply -var-file="dev.tfvars"

# Staging
terraform apply -var-file="stag.tfvars"

# Production
terraform apply -var-file="prod.tfvars"
```

Each environment is isolated with its own:
- VPC and networking resources
- Security groups
- EC2 instances
- Resource tags

## 🔍 Key Features

### Bash-based Backend Setup
- **Automated Setup**: One script to create all backend resources
- **Comprehensive Logging**: Color-coded output with detailed logs
- **Idempotent Operations**: Safe to run multiple times
- **State Tracking**: Tracks created resources in `.tfstate.env`
- **Pre-flight Checks**: Validates AWS CLI and credentials before execution

### Remote State Management
- **S3 Backend**: Centralized, versioned state storage
- **DynamoDB Locking**: Prevents concurrent state modifications
- **Encryption**: State files encrypted at rest (AES256)
- **Versioning**: Track state file history
- **Public Access Blocked**: S3 bucket secured against public access

### Security Best Practices
- **Public Access Blocking**: S3 bucket not publicly accessible
- **Encryption**: Server-side encryption for state files
- **Security Groups**: Restrictive ingress/egress rules
- **SSH Access**: Limited to VPC CIDR only

### Modular Design
- **Reusable Modules**: Network, Security, and Compute modules
- **Separation of Concerns**: Each module handles specific resources
- **Easy Maintenance**: Update modules independently
- **Scalability**: Add new modules without affecting existing ones

### Infrastructure Highlights
- **Auto-configured Web Server**: Nginx installed via user data
- **Custom Landing Page**: Dynamic HTML with environment info
- **Public IP Assignment**: Instances accessible from internet
- **Latest Ubuntu AMI**: Automatically fetches Ubuntu 22.04 LTS
- **Metadata Service**: IMDSv2 configured for enhanced security

## 📊 Outputs

After deployment, Terraform provides these outputs:

### Network Outputs
- `vpc_id`: VPC identifier
- `vpc_cidr`: VPC CIDR block
- `public_subnet_id`: Public subnet identifier
- `internet_gateway_id`: Internet gateway identifier
- `public_route_table_id`: Route table identifier

### Security Outputs
- `app_security_group_id`: Security group ID
- `app_security_group_name`: Security group name
- `app_security_group_rules`: List of security rules

### Compute Outputs
### Test Backend Setup

```bash
# Test 1: Verify S3 bucket exists
aws s3 ls s3://iac-terraform-dev-tfstate --region eu-west-1

# Test 2: Check DynamoDB table
aws dynamodb describe-table --table-name iac-terraform-dev-tfstate-lock --region eu-west-1

# Test 3: Review setup logs
cat scripts/terraform-backend.log

# Test 4: Check state file
cat scripts/.tfstate.env
```

### Test Infrastructure Deploymentstance identifier
- `instance_public_ip`: Public IP address
- `instanceBackend script fails
- **Check AWS CLI**: Run `aws --version` to verify installation
- **Verify Credentials**: Run `aws sts get-caller-identity`
- **Review Logs**: Check `scripts/terraform-backend.log` for details
- **IAM Permissions**: Ensure S3 and DynamoDB create permissions
- **Region Validation**: Confirm region is valid and accessible

### Issue: Bucket already exists
- **Idempotent Script**: The script checks for existing resources
- **State File**: Check `scripts/.tfstate.env` for tracked resources
- **Manual Check**: Run `aws s3 ls` to see your buckets
- **Force Recreation**: Delete resources manually if needed

### Issue: Website not loading
- **Wait**: Allow 2-3 minutes for user data script to complete
- **Check Security Group**: Ensure port 80 is open (0.0.0.0/0)
- **Verify Public IP**: Confirm instance has a public IP assigned
- **Check Nginx**: SSH into instance and run `sudo systemctl status nginx`

### Issue: Backend initialization failed
- **Verify S3 Bucket**: Ensure setup script complet
```bash
# Test 1: Check Terraform outputs
terraform output

# Test 2: Verify HTTP access
curl http://$(terraform output -raw instance_public_ip)

# Test 3: SSH into instance (if you have the key)
ssh -i /path/to/your-key.pem ubuntu@$(terraform output -raw instance_public_ip)

# Test 4: Check Nginx status (from SSH)
sudo systemctl status nginx
```
Step 1: Destroy main infrastructure
cd infrastructure/
terraform destroy -var-file="dev.tfvars"

# Step 2: Delete backend resources (manual)
# Note: S3 bucket must be empty before deletion

# List and delete all objects in the bucket
aws s3 rm s3://iac-terraform-dev-tfstate --recursive --region eu-west-1

# Delete the S3 bucket
aws s3api delete-bucket \
    --bucket iac-terraform-dev-tfstate \
    --region eu-west-1

# Delete the DynamoDB table
aws dynamodb delete-table \
    --table-name iac-terraform-dev-tfstate-lock \
    --region eu-west-1

# Step 3: Clean up state files
cd ../scripts/
rm -f .tfstate.env terraform-backend.log
### Issue: Backend initialization failed
- **Verify S3 Bucket**: Ensure bootstrap was applied successfully
- **Check IAM Permissions**: Confirm S3 and DynamoDB access
- **Validate Region**: Ensure backend region matches bucket region

### Issue: SSH connection refused
- **Security Group**: SSH is restricted to VPC CIDR only
- **Key Pair**: Verify you're using the correct SSH key
- **Bastion Host**: Consider setting up a bastion for SSH access

### Issue: State locking errors
- **Check DynamoDB**: Verify table exists and is accessible
- **Force Unlock**: `terraform force-unlock <lock-id>` (use carefully)
- **Permissions**: Ensure DynamoDB read/write permissions

## 🧹 Cleanup

To destroy all resources and avoid AWS charges:

```bash
# Destroy main infrastructure
cd infrastructure/
terraform destroy -var-file="dev.tfvars"

# Note: S3 bucket must be empty before deletion
```

⚠️ **Warning**: This will permanently delete all resources. Ensure you have backups if needed.

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## 🤝 Contributing

To contribute to this project:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

**Project Status**: ✅ Deployed and Operational

**Last Updated**: January 2026

**Maintained By**: Joel Livingstone Kofi Ackah
