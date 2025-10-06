# terraform/versions.tf

terraform {
  # Configure S3 backend for remote state (CRITICAL: Bucket and Table must exist)
  backend "s3" {
    bucket         = "jsarroyo-eks-tf-state" 
    key            = "eks/vpc/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "jsarroyo-tf-lock" 
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.13.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0"
    }
    local = {
        source  = "hashicorp/local"
        version = ">= 2.0.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.aws_region
}

# Data source for the EKS authentication token
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}