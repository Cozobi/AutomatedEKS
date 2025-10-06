# terraform/variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"  
}

variable "project_name" {
  description = "The base name for all resources"
  type        = string
  default     = "jsarroyo-eks-testing"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16" 
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets (e.g., for Load Balancers)"
  type        = list(string)
  default     = ["10.1.101.0/24", "10.1.102.0/24"] # Spread across 2 AZs
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets (for EKS Worker Nodes)"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"] # Spread across 2 AZs
}