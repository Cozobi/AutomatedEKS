# terraform/vpc.tf

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "IDs of the public subnets (for Load Balancers)"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "IDs of the private subnets (for EKS Worker Nodes)"
  value       = module.vpc.private_subnets
}