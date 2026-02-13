# oidc.tf - OIDC Provider for EKS (enables IRSA - IAM Roles for Service Accounts)

# TLS certificate for OIDC provider
data "tls_certificate" "eks" {
  count = var.eks_cluster_role_arn != "" ? 1 : 0
  url   = aws_eks_cluster.main[0].identity[0].oidc[0].issuer
}

# IAM OIDC Identity Provider for EKS
resource "aws_iam_openid_connect_provider" "eks" {
  count = var.eks_cluster_role_arn != "" ? 1 : 0

  url             = aws_eks_cluster.main[0].identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks[0].certificates[0].sha1_fingerprint]

  tags = {
    Name        = "${var.project_name}-eks-oidc-provider"
    Environment = var.environment
  }
}
