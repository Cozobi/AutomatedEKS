# terraform/main.tf

# 1. Data Source for AZs
data "aws_availability_zones" "available" {}

# 2. VPC Module Call (Networking)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  
  name                 = var.project_name
  cidr                 = var.vpc_cidr
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  
  azs = slice(data.aws_availability_zones.available.names, 0, length(var.private_subnets))
  
  tags = {
    "kubernetes.io/cluster/${var.project_name}" = "owned"
    "Environment"                                = "DevOps-Demo"
  }
}

# 3. EKS Cluster Module Call (Container Platform)
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"

  cluster_name    = var.project_name
  cluster_version = "1.29"

  # Networking Configuration
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets
  
  # SECURITY FIX: Opens the API endpoint completely for deployment success.
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false # CRITICAL FIX: Forces DNS to public IP
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] 
  
  # Configuration and Add-ons
  enable_irsa = true
  cluster_addons = {
    vpc-cni = { resolve_conflicts = "OVERWRITE" }
    coredns      = {}
    kube-proxy   = {}
  }

  # EKS Managed Node Group (Worker Nodes)
  eks_managed_node_groups = {
    general_purpose = {
      name           = "workers-private"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      subnet_ids     = module.vpc.private_subnets 
      tags = {
        "kubernetes.io/cluster/${var.project_name}" = "owned" 
      }
    }
  }
  tags = { Environment = "DevOps-Demo" }
}

# 4. Dynamic Kubeconfig File Generator (CRITICAL FIX for Helm connectivity)
resource "local_file" "kubeconfig" {
  content  = <<-EOT
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${module.eks.cluster_certificate_authority_data}
    server: ${module.eks.cluster_endpoint}
  name: ${module.eks.cluster_name}
contexts:
- context:
    cluster: ${module.eks.cluster_name}
    user: ${module.eks.cluster_name}
  name: ${module.eks.cluster_name}
current-context: ${module.eks.cluster_name}
kind: Config
preferences: {}
users:
- name: ${module.eks.cluster_name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${module.eks.cluster_name}"
        - "--region"
        - "${var.aws_region}"
EOT
  # File will be written to the same directory as main.tf
  filename = "${path.module}/kubeconfig_${module.eks.cluster_name}" 
  depends_on = [module.eks] 
  
  # Corrected lifecycle block (removes invalid arguments)
  lifecycle {}
}

# 5. Dynamic Provider Configuration (The FIX to bypass Helm syntax errors)
provider "kubernetes" {
  config_path = local_file.kubeconfig.filename
}

provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
  }
}

# 6. AWS Load Balancer Controller (Application networking resource - commented out for manual deployment)
# This is left commented out as per our troubleshooting resolution.
/*
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  depends_on = [module.eks.eks_managed_node_groups]
  
  set = [
    { name  = "clusterName", value = module.eks.cluster_name },
    { name  = "serviceAccount.create", value = "true" },
    { name  = "serviceAccount.name", value = "aws-load-balancer-controller" },
    { name  = "image.repository", value = "public.ecr.aws/eks-distro/aws-load-balancer-controller/controller" },
    { name  = "region", value = var.aws_region }
  ]
}
*/