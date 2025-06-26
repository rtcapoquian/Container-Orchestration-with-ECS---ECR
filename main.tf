# Container Orchestration with ECS & ECR
# Main Terraform configuration for containerized microservices
# Author: Reji Capoquian

# This infrastructure includes:
# - ECR repositories for container images
# - ECS cluster with Fargate
# - Application Load Balancer
# - VPC with public/private subnets
# - Security groups
# - CloudWatch logging
# - CodePipeline for CI/CD
# - Service discovery and secret management

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values
locals {
  project_name = "ecs-microservices"
  environment  = "dev"

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "terraform"
    Owner       = "reji-capoquian"
  }
}
