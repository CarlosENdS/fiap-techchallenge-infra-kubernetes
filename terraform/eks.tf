resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.project_name}-eks-cluster-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for EKS cluster control plane"

  ingress {
    description = "Allow HTTPS from workers"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      aws_subnet.private_1.cidr_block,
      aws_subnet.private_2.cidr_block
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-cluster-sg-${var.environment}"
  }
}

resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.project_name}-eks-nodes-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for EKS worker nodes"

  ingress {
    description = "Allow nodes to communicate with each other"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Allow pods to communicate with cluster API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-nodes-sg-${var.environment}"
    "kubernetes.io/cluster/${var.project_name}-eks-${var.environment}" = "owned"
  }
}

resource "aws_security_group_rule" "nodes_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.rds.id
  description              = "Allow EKS nodes to access RDS"
}

resource "aws_eks_cluster" "main" {
  count = var.eks_cluster_role_arn != "" ? 1 : 0

  name     = "${var.project_name}-eks-${var.environment}"
  role_arn = var.eks_cluster_role_arn
  version  = "1.28"  # Versão estável do Kubernetes

  vpc_config {
    subnet_ids = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id,
      aws_subnet.public_1.id,
      aws_subnet.public_2.id
    ]
    
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true  # Para acessar de fora (kubectl)
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  tags = {
    Name = "${var.project_name}-eks-${var.environment}"
  }

  depends_on = [
    aws_vpc.main,
    aws_subnet.private_1,
    aws_subnet.private_2
  ]
}

resource "aws_eks_node_group" "main" {
  count = var.eks_node_role_arn != "" && var.eks_cluster_role_arn != "" ? 1 : 0

  cluster_name    = aws_eks_cluster.main[0].name
  node_group_name = "${var.project_name}-node-group-${var.environment}"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  scaling_config {
    desired_size = 2  
    min_size     = 2  
    max_size     = 4  
  }

  instance_types = ["t3.medium"]  # 2 vCPU, 4GB RAM

  disk_size = 20  # GB

  ami_type = "AL2_x86_64"  # Amazon Linux 2

  update_config {
    max_unavailable = 1  # Máximo de nodes indisponíveis durante update
  }

  labels = {
    Environment = var.environment
    Project     = var.project_name
  }

  tags = {
    Name = "${var.project_name}-eks-nodes-${var.environment}"
    "kubernetes.io/cluster/${var.project_name}-eks-${var.environment}" = "owned"
  }

  depends_on = [aws_eks_cluster.main]
}

resource "aws_eks_addon" "vpc_cni" {
  count = var.eks_cluster_role_arn != "" ? 1 : 0

  cluster_name = aws_eks_cluster.main[0].name
  addon_name   = "vpc-cni"
  
  addon_version = "v1.15.1-eksbuild.1" 

  depends_on = [aws_eks_node_group.main]
}

resource "aws_eks_addon" "coredns" {
  count = var.eks_cluster_role_arn != "" ? 1 : 0

  cluster_name = aws_eks_cluster.main[0].name
  addon_name   = "coredns"
  
  addon_version = "v1.10.1-eksbuild.6"

  depends_on = [aws_eks_node_group.main]
}

resource "aws_eks_addon" "kube_proxy" {
  count = var.eks_cluster_role_arn != "" ? 1 : 0

  cluster_name = aws_eks_cluster.main[0].name
  addon_name   = "kube-proxy"
  
  addon_version = "v1.28.2-eksbuild.2"

  depends_on = [aws_eks_node_group.main]
}