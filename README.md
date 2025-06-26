# Container Orchestration with ECS & ECR

## Cloud Engineering Project by Reji Capoquian

This project demonstrates a comprehensive container orchestration solution using Amazon ECS with Fargate, ECR, and a complete CI/CD pipeline built with AWS CodePipeline.

## Architecture Overview

### Technologies Used

- **AWS ECS** - Container orchestration service
- **AWS ECR** - Container registry
- **AWS Fargate** - Serverless container compute
- **AWS CodePipeline** - CI/CD pipeline
- **AWS CodeBuild** - Build service
- **Docker** - Containerization
- **CloudWatch** - Monitoring and logging
- **Terraform** - Infrastructure as Code

### Infrastructure Components

1. **Networking**

   - VPC with public and private subnets across 2 AZs
   - Internet Gateway and NAT Gateways
   - Security Groups for different components

2. **Container Services**

   - ECS Cluster with Fargate capacity providers
   - ECR repositories for frontend and backend
   - Service discovery with AWS Cloud Map

3. **Load Balancing**

   - Application Load Balancer
   - Target groups for frontend and backend services
   - Health checks and routing rules

4. **CI/CD Pipeline**

   - CodePipeline for automated deployments
   - CodeBuild for container image builds
   - GitHub integration for source control

5. **Monitoring & Security**
   - CloudWatch logging and metrics
   - CloudWatch Dashboard
   - AWS Secrets Manager for sensitive data
   - KMS encryption

## Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** >= 1.0 installed
3. **Docker** installed (for local testing)
4. **GitHub** repositories for your applications
5. **GitHub Personal Access Token** with repo permissions

## Quick Start

### 1. Clone and Setup

```bash
git clone <this-repository>
cd ecs-devops
```

### 2. Configure Variables

Copy the example variables file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update the following in `terraform.tfvars`:

- `github_token` - Your GitHub personal access token
- `github_username` - Your GitHub username
- `frontend_repo` - Your frontend repository name
- `backend_repo` - Your backend repository name
- `alert_email` - Your email for CloudWatch alerts

### 3. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the infrastructure
terraform apply
```

### 4. Setup Application Repositories

Create GitHub repositories with the following structure:

#### Frontend Repository Structure

```
frontend-repo/
├── Dockerfile
├── buildspec-frontend.yml
├── src/
│   └── (your frontend code)
├── package.json
└── README.md
```

#### Backend Repository Structure

```
backend-repo/
├── Dockerfile
├── buildspec-backend.yml
├── src/
│   └── (your backend code)
├── package.json
└── README.md
```

### 5. Sample Dockerfile Examples

#### Frontend Dockerfile (React/Node.js)

```dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
```

#### Backend Dockerfile (Node.js API)

```dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 8080

CMD ["npm", "start"]
```

## Infrastructure Details

### ECS Services Configuration

- **Frontend Service**:

  - Runs on port 3000
  - 2 tasks by default
  - 256 CPU units, 512 MB memory
  - Health check on `/health` endpoint

- **Backend Service**:
  - Runs on port 8080
  - 2 tasks by default
  - 512 CPU units, 1024 MB memory
  - Health check on `/health` endpoint

### Load Balancer Configuration

- **Port 80**: Routes to frontend service (default)
- **Port 8080**: Routes to backend service
- **Path `/api/*`**: Routes to backend service on port 80

### Service Discovery

Services can communicate using:

- `frontend.ecs-microservices.local:3000`
- `backend.ecs-microservices.local:8080`

## Monitoring and Debugging

### CloudWatch Dashboard

Access your monitoring dashboard:

```
https://ap-southeast-1.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-1#dashboards:name=ecs-microservices-dashboard
```

### ECS Exec for Debugging

Connect to running containers:

```bash
# Frontend container
aws ecs execute-command \
  --cluster ecs-microservices-cluster \
  --task <task-id> \
  --container frontend \
  --interactive \
  --command "/bin/bash"

# Backend container
aws ecs execute-command \
  --cluster ecs-microservices-cluster \
  --task <task-id> \
  --container backend \
  --interactive \
  --command "/bin/bash"
```

### Viewing Logs

```bash
# Frontend logs
aws logs tail /ecs/ecs-microservices/frontend --follow

# Backend logs
aws logs tail /ecs/ecs-microservices/backend --follow
```

## CI/CD Pipeline

### Pipeline Stages

1. **Source**: Pulls code from GitHub
2. **Build**:
   - Builds Docker images
   - Pushes to ECR
   - Creates image definitions
3. **Deploy**: Updates ECS service with new image

### Manual Pipeline Trigger

```bash
# Start frontend pipeline
aws codepipeline start-pipeline-execution \
  --name ecs-microservices-frontend-pipeline

# Start backend pipeline
aws codepipeline start-pipeline-execution \
  --name ecs-microservices-backend-pipeline
```

## Security Features

### Secrets Management

Application secrets are stored in AWS Secrets Manager:

- Database credentials
- API keys
- JWT secrets

### Network Security

- Services run in private subnets
- Security groups restrict access
- VPC endpoints for AWS services

### Container Security

- ECR vulnerability scanning enabled
- Images encrypted at rest
- Least privilege IAM roles

## Scaling Configuration

### Auto Scaling (Optional)

Add auto scaling policies:

```hcl
resource "aws_appautoscaling_target" "frontend" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
```

## Cost Optimization

### Development Environment

For development, you can reduce costs by:

1. Using FARGATE_SPOT capacity provider
2. Reducing task counts to 1
3. Using smaller CPU/memory allocations
4. Single NAT Gateway configuration

Update `terraform.tfvars`:

```hcl
frontend_desired_count = 1
backend_desired_count  = 1
single_nat_gateway     = true
```

## Troubleshooting

### Common Issues

1. **Service not starting**: Check CloudWatch logs for container errors
2. **Health check failing**: Ensure your application responds on `/health`
3. **Pipeline failing**: Check CodeBuild logs and IAM permissions
4. **Can't access application**: Verify security groups and target group health

### Useful Commands

```bash
# Check ECS service status
aws ecs describe-services \
  --cluster ecs-microservices-cluster \
  --services ecs-microservices-frontend ecs-microservices-backend

# Check target group health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>

# Check ECR repositories
aws ecr describe-repositories

# Check pipeline status
aws codepipeline get-pipeline-state \
  --name ecs-microservices-frontend-pipeline
```

## Cleanup

To destroy all resources:

```bash
# Empty ECR repositories first
aws ecr batch-delete-image \
  --repository-name ecs-microservices/frontend \
  --image-ids imageTag=latest

aws ecr batch-delete-image \
  --repository-name ecs-microservices/backend \
  --image-ids imageTag=latest

# Destroy infrastructure
terraform destroy
```

## Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS Fargate Documentation](https://docs.aws.amazon.com/fargate/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Project Structure

```
├── main.tf                     # Main configuration
├── provider.tf                 # AWS provider configuration
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
├── vpc.tf                      # VPC and networking
├── security-groups.tf          # Security groups
├── ecr.tf                      # ECR repositories
├── ecs.tf                      # ECS cluster and services
├── load-balancer.tf            # Application Load Balancer
├── iam.tf                      # IAM roles and policies
├── secrets.tf                  # Secrets and KMS
├── cloudwatch.tf               # Monitoring and logging
├── codepipeline.tf             # CI/CD pipeline
├── buildspec-frontend.yml      # Frontend build specification
├── buildspec-backend.yml       # Backend build specification
├── terraform.tfvars.example    # Example variables
└── README.md                   # This file
```

---

**Author**: Reji Capoquian  
**Project**: Container Orchestration with ECS & ECR  
**Level**: Intermediate Cloud Engineering
