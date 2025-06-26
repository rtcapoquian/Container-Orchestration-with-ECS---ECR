# Secret Management for ECS Services

# KMS Key for ECS
resource "aws_kms_key" "ecs" {
  description             = "KMS key for ECS encryption"
  deletion_window_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-ecs-kms"
  })
}

# KMS Key Alias
resource "aws_kms_alias" "ecs" {
  name          = "alias/${local.project_name}-ecs"
  target_key_id = aws_kms_key.ecs.key_id
}

# Secrets Manager Secret
resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${local.project_name}-app-secrets"
  description             = "Application secrets for ${local.project_name}"
  recovery_window_in_days = 7

  tags = local.common_tags
}

# Secret Version with initial values
resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    api_key      = "your-api-key-here"
    database_url = "postgresql://username:password@hostname:5432/dbname"
    jwt_secret   = "your-jwt-secret-here"
    redis_url    = "redis://redis-host:6379"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Parameter Store for non-sensitive configuration
resource "aws_ssm_parameter" "app_environment" {
  name  = "/${local.project_name}/environment"
  type  = "String"
  value = local.environment

  tags = local.common_tags
}

resource "aws_ssm_parameter" "app_region" {
  name  = "/${local.project_name}/region"
  type  = "String"
  value = data.aws_region.current.id

  tags = local.common_tags
}

resource "aws_ssm_parameter" "frontend_url" {
  name  = "/${local.project_name}/frontend-url"
  type  = "String"
  value = "http://${aws_lb.main.dns_name}"

  tags = local.common_tags
}

resource "aws_ssm_parameter" "backend_url" {
  name  = "/${local.project_name}/backend-url"
  type  = "String"
  value = "http://${aws_lb.main.dns_name}:8080"

  tags = local.common_tags
}
