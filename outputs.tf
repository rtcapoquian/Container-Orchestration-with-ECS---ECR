# Outputs for ECS Microservices Infrastructure

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "ecs_cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "load_balancer_dns_name" {
  description = "Load Balancer DNS Name"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Load Balancer Zone ID"
  value       = aws_lb.main.zone_id
}

output "frontend_service_name" {
  description = "Frontend ECS Service Name"
  value       = aws_ecs_service.frontend.name
}

output "backend_service_name" {
  description = "Backend ECS Service Name"
  value       = aws_ecs_service.backend.name
}

output "frontend_ecr_repository_url" {
  description = "Frontend ECR Repository URL"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repository_url" {
  description = "Backend ECR Repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_target_group_arn" {
  description = "Frontend Target Group ARN"
  value       = aws_lb_target_group.frontend.arn
}

output "backend_target_group_arn" {
  description = "Backend Target Group ARN"
  value       = aws_lb_target_group.backend.arn
}

output "codepipeline_bucket_name" {
  description = "CodePipeline S3 Bucket Name"
  value       = aws_s3_bucket.codepipeline.bucket
}

output "secrets_manager_secret_arn" {
  description = "Secrets Manager Secret ARN"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "service_discovery_namespace_id" {
  description = "Service Discovery Namespace ID"
  value       = aws_service_discovery_private_dns_namespace.main.id
}

output "frontend_log_group_name" {
  description = "Frontend CloudWatch Log Group Name"
  value       = aws_cloudwatch_log_group.frontend.name
}

output "backend_log_group_name" {
  description = "Backend CloudWatch Log Group Name"
  value       = aws_cloudwatch_log_group.backend.name
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value       = "https://${data.aws_region.current.id}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.id}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "application_urls" {
  description = "Application URLs"
  value = {
    frontend = "http://${aws_lb.main.dns_name}"
    backend  = "http://${aws_lb.main.dns_name}:8080"
    api      = "http://${aws_lb.main.dns_name}/api"
  }
}

output "ecs_exec_commands" {
  description = "ECS Exec Commands for debugging"
  value = {
    frontend = "aws ecs execute-command --cluster ${aws_ecs_cluster.main.name} --task <task-id> --container frontend --interactive --command \"/bin/bash\""
    backend  = "aws ecs execute-command --cluster ${aws_ecs_cluster.main.name} --task <task-id> --container backend --interactive --command \"/bin/bash\""
  }
}

output "ecr_login_commands" {
  description = "ECR Login Commands"
  value = {
    frontend = "aws ecr get-login-password --region ${data.aws_region.current.id} | docker login --username AWS --password-stdin ${aws_ecr_repository.frontend.repository_url}"
    backend  = "aws ecr get-login-password --region ${data.aws_region.current.id} | docker login --username AWS --password-stdin ${aws_ecr_repository.backend.repository_url}"
  }
}

output "codepipeline_names" {
  description = "CodePipeline Names"
  value = {
    frontend = aws_codepipeline.frontend.name
    backend  = aws_codepipeline.backend.name
  }
}

output "security_group_ids" {
  description = "Security Group IDs"
  value = {
    alb         = aws_security_group.alb.id
    ecs_service = aws_security_group.ecs_service.id
    rds         = aws_security_group.rds.id
  }
}
