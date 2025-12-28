variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"  
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "cargarage"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default" 
}

variable "eks_cluster_role_arn" {
  description = "ARN of the pre-existing IAM role for EKS cluster"
  type        = string
  default     = ""
}

variable "eks_node_role_arn" {
  description = "ARN of the pre-existing IAM role for EKS nodes"
  type        = string
  default     = ""
}