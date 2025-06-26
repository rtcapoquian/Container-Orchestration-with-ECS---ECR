#!/bin/bash

# ECS Microservices Deployment Script
# Author: Reji Capoquian

set -e

echo "🚀 ECS Microservices Infrastructure Deployment"
echo "=============================================="

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not found. Please install Terraform first."
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "⚠️  terraform.tfvars not found. Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "📝 Please edit terraform.tfvars with your values before continuing."
    echo "   Required variables:"
    echo "   - github_token"
    echo "   - github_username"
    echo "   - frontend_repo"
    echo "   - backend_repo"
    echo "   - alert_email"
    read -p "Press Enter after editing terraform.tfvars..."
fi

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Format Terraform files
echo "🎨 Formatting Terraform files..."
terraform fmt

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Ask for confirmation
echo ""
echo "🤔 Review the plan above. Do you want to proceed with deployment?"
read -p "Type 'yes' to continue: " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Deployment cancelled."
    exit 1
fi

# Apply deployment
echo "🚀 Deploying infrastructure..."
terraform apply tfplan

# Clean up plan file
rm -f tfplan

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📊 Infrastructure Overview:"
echo "=========================="
terraform output -json | jq -r '
  "🔗 Load Balancer DNS: " + .load_balancer_dns_name.value,
  "🌐 Frontend URL: " + .application_urls.value.frontend,
  "🔧 Backend API URL: " + .application_urls.value.backend,
  "📈 CloudWatch Dashboard: " + .cloudwatch_dashboard_url.value,
  "",
  "📦 ECR Repositories:",
  "   Frontend: " + .frontend_ecr_repository_url.value,
  "   Backend: " + .backend_ecr_repository_url.value,
  "",
  "🔧 ECS Cluster: " + .ecs_cluster_name.value
'

echo ""
echo "📝 Next Steps:"
echo "=============="
echo "1. Create your GitHub repositories:"
echo "   - Frontend: https://github.com/$(terraform output -raw github_username 2>/dev/null || echo 'your-username')/$(terraform output -raw frontend_repo 2>/dev/null || echo 'frontend-repo')"
echo "   - Backend: https://github.com/$(terraform output -raw github_username 2>/dev/null || echo 'your-username')/$(terraform output -raw backend_repo 2>/dev/null || echo 'backend-repo')"
echo ""
echo "2. Copy sample application code from examples/ directory"
echo ""
echo "3. Push code to repositories to trigger CI/CD pipeline"
echo ""
echo "4. Monitor deployment in AWS Console:"
echo "   - ECS Console: https://console.aws.amazon.com/ecs/"
echo "   - CodePipeline: https://console.aws.amazon.com/codesuite/codepipeline/"
echo ""
echo "✨ Happy coding!"
