@echo off
setlocal enabledelayedexpansion

REM ECS Microservices Deployment Script for Windows
REM Author: Reji Capoquian

echo 🚀 ECS Microservices Infrastructure Deployment
echo ==============================================

REM Check prerequisites
echo 📋 Checking prerequisites...

where terraform >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Terraform not found. Please install Terraform first.
    exit /b 1
)

where aws >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ AWS CLI not found. Please install AWS CLI first.
    exit /b 1
)

REM Check AWS credentials
aws sts get-caller-identity >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ AWS credentials not configured. Please run 'aws configure' first.
    exit /b 1
)

echo ✅ Prerequisites check passed

REM Check if terraform.tfvars exists
if not exist "terraform.tfvars" (
    echo ⚠️  terraform.tfvars not found. Creating from example...
    copy terraform.tfvars.example terraform.tfvars
    echo 📝 Please edit terraform.tfvars with your values before continuing.
    echo    Required variables:
    echo    - github_token
    echo    - github_username
    echo    - frontend_repo
    echo    - backend_repo
    echo    - alert_email
    pause
)

REM Initialize Terraform
echo 🔧 Initializing Terraform...
terraform init
if %errorlevel% neq 0 exit /b %errorlevel%

REM Validate configuration
echo ✅ Validating Terraform configuration...
terraform validate
if %errorlevel% neq 0 exit /b %errorlevel%

REM Format Terraform files
echo 🎨 Formatting Terraform files...
terraform fmt

REM Plan deployment
echo 📋 Planning deployment...
terraform plan -out=tfplan
if %errorlevel% neq 0 exit /b %errorlevel%

REM Ask for confirmation
echo.
echo 🤔 Review the plan above. Do you want to proceed with deployment?
set /p confirm="Type 'yes' to continue: "

if not "!confirm!"=="yes" (
    echo ❌ Deployment cancelled.
    exit /b 1
)

REM Apply deployment
echo 🚀 Deploying infrastructure...
terraform apply tfplan
if %errorlevel% neq 0 exit /b %errorlevel%

REM Clean up plan file
del tfplan

echo.
echo 🎉 Deployment completed successfully!
echo.
echo 📊 Infrastructure Overview:
echo ==========================
terraform output load_balancer_dns_name
terraform output application_urls
terraform output ecs_cluster_name

echo.
echo 📝 Next Steps:
echo ==============
echo 1. Create your GitHub repositories
echo 2. Copy sample application code from examples/ directory
echo 3. Push code to repositories to trigger CI/CD pipeline
echo 4. Monitor deployment in AWS Console
echo.
echo ✨ Happy coding!

pause
