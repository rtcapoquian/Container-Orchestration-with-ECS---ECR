# VPC Endpoints for AWS Services

# VPC Endpoint for ECR API
resource "aws_vpc_endpoint" "ecr_api" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${data.aws_region.current.id}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-ecr-api-endpoint"
  })
}

# VPC Endpoint for ECR Docker
resource "aws_vpc_endpoint" "ecr_dkr" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${data.aws_region.current.id}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-ecr-dkr-endpoint"
  })
}

# VPC Endpoint for S3 (Gateway endpoint)
resource "aws_vpc_endpoint" "s3" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-s3-endpoint"
  })
}

# VPC Endpoint for CloudWatch Logs
resource "aws_vpc_endpoint" "logs" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${data.aws_region.current.id}.logs"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-logs-endpoint"
  })
}

# VPC Endpoint for Secrets Manager
resource "aws_vpc_endpoint" "secretsmanager" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${data.aws_region.current.id}.secretsmanager"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-secretsmanager-endpoint"
  })
}

# VPC Endpoint for SSM
resource "aws_vpc_endpoint" "ssm" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${data.aws_region.current.id}.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-ssm-endpoint"
  })
}

# VPC Endpoint for SSM Messages
resource "aws_vpc_endpoint" "ssmmessages" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${data.aws_region.current.id}.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-ssmmessages-endpoint"
  })
}

# VPC Endpoint for KMS
resource "aws_vpc_endpoint" "kms" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${data.aws_region.current.id}.kms"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-kms-endpoint"
  })
}
