output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  description = "ARN of the AWS caller identity"
  value       = data.aws_caller_identity.current.arn
}

# ==============================================================================
# NETWORK OUTPUTS
# ==============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "availability_zones" {
  description = "Availability zones used"
  value       = [aws_subnet.public_1.availability_zone, aws_subnet.public_2.availability_zone]
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# ==============================================================================
# ECR OUTPUTS
# ==============================================================================

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.app.arn
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.app.name
}

output "ecr_docker_login_command" {
  description = "Command to login to ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app.repository_url}"
}


# ==============================================================================
# EKS OUTPUTS
# ==============================================================================

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = var.eks_cluster_role_arn != "" ? aws_eks_cluster.main[0].endpoint : null
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = var.eks_cluster_role_arn != "" ? aws_eks_cluster.main[0].name : null
}

output "eks_cluster_security_group_id" {
  description = "Security group ID for EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "eks_node_group_name" {
  description = "EKS node group name"
  value       = var.eks_node_role_arn != "" && var.eks_cluster_role_arn != "" ? aws_eks_node_group.main[0].node_group_name : null
}

output "eks_kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = var.eks_cluster_role_arn != "" ? "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main[0].name}" : "EKS cluster not created - roles not provided"
}

output "eks_nodes_security_group_id" {
  description = "Security group ID for EKS Nodes"
  value       = aws_security_group.eks_nodes.id
}

output "eks_cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for EKS cluster (used for IRSA)"
  value       = var.eks_cluster_role_arn != "" ? aws_eks_cluster.main[0].identity[0].oidc[0].issuer : null
}

output "eks_cluster_certificate_authority" {
  description = "EKS cluster certificate authority data"
  value       = var.eks_cluster_role_arn != "" ? aws_eks_cluster.main[0].certificate_authority[0].data : null
  sensitive   = true
}