Automated EKS Microservice Deployment (Cloud Network Engineer Project)
Project Name
Secure EKS Cluster Deployment with Automated Ingress and CI/CD Foundation

Description
This project provisions a production-ready Amazon EKS (Elastic Kubernetes Service) cluster and its entire networking stack using Terraform. The primary goal is to demonstrate expertise in Cloud Networking, Infrastructure as Code (IaC), Security Best Practices (private nodes), and establishing a robust platform for Containerization.

The application is deployed to private worker nodes and exposed securely via a public AWS Application Load Balancer (ALB), which is provisioned dynamically by the AWS Load Balancer Controller installed inside the cluster.

Key Features Demonstrated:
Secure Networking: EKS Worker Nodes are isolated in private subnets, ensuring no direct internet exposure.

IaC Implementation: Full infrastructure (VPC, EKS, IAM, Load Balancer Controller) is managed via Terraform modules.

IAM & Auth: Demonstrates fixing EKS authentication gaps by manually patching the aws-auth ConfigMap to grant administrative access.

Deployment Automation: Includes a buildspec.yml to define the steps for a continuous deployment pipeline (CodeBuild).

Architecture Topology
This diagram illustrates the separation of concerns between public and private networking layers, the security boundary of the EKS cluster, and the path of traffic flow.

Component

Network Layer

Role

ALB (Application Load Balancer)

Public Subnets

Receives external HTTPS traffic and forwards it to private Pod IPs.

NAT Gateway

Public Subnets

Allows private EKS nodes to pull external resources (e.g., Docker images from ECR) while blocking inbound traffic.

EKS Control Plane

AWS Managed

Orchestrates the Kubernetes cluster and is accessed via the Public Endpoint.

EKS Worker Nodes

Private Subnets

Hosts the application Pods (containers) securely behind the firewall.

Traffic Flow

Internet → ALB → Private Pods

Ingress traffic enters via the public ALB and is directed to target Pods running in the private subnets.

Resources Utilized (AWS & Tools)
Category

Resources/Tools

Purpose

Networking

aws_vpc, aws_subnet (Public/Private), aws_nat_gateway

Provides isolated, highly-available network foundation for EKS.

Compute

aws_eks_cluster, eks_managed_node_groups

Managed Kubernetes control plane and secure worker nodes.

Containerization

AWS ECR, Docker, Kubernetes Deployments, Services

Container registry, application packaging, and workload orchestration.

Load Balancing

helm_release (ALB Controller), Kubernetes Ingress

Provisions the public AWS Application Load Balancer to expose services.

IaC/DevOps

Terraform (helm, kubernetes providers), local_file, buildspec.yml

Infrastructure definition and automation logic.

Quick Start Guide: Deployment Steps
This project requires a two-phase deployment: first the infrastructure via Terraform, and then the application via kubectl.

Phase 1: Deploy Infrastructure (Terraform)
Run these commands from the terraform/ directory.

Step

Command

Notes

1. Prerequisites

(Manual)

Ensure AWS CLI, Docker, kubectl, and Helm are installed and configured. Create the S3 bucket (jsarroyo-eks-tf-state) and DynamoDB table (jsarroyo-tf-lock) manually for the remote state backend.

2. Initialize

terraform init

Downloads providers/modules and sets up the remote state backend.

3. Plan

terraform plan

Verifies configuration (should show ~70 resources to add).

4. Apply

terraform apply --auto-approve

Provisions the VPC, EKS Cluster, and Worker Nodes. (Takes 10-15 minutes).

Phase 2: Gain Access and Deploy Application
Once Phase 1 is complete, you must grant your IAM role administrative access to the cluster and deploy the application.

Step

Command

Description

1. Configure Access

aws eks update-kubeconfig --region us-east-1 --name jsarroyo-eks-testing

Updates your local ~/.kube/config to enable IAM authentication. (May need to be run several times if your IAM token is expired).

2. Patch Auth

kubectl apply --validate=false -f ../app/patch.yaml

CRITICAL: Patches the aws-auth ConfigMap to grant your current IAM role system:masters permissions (admin access).

3. Verify Nodes

kubectl get nodes

Confirms successful access and should show your worker nodes as Ready.

4. ECR Push

(Manual)

Build your application image, tag it with your ECR URI and a tag (e.g., v1.0.0), and push it to your registry.

5. Deploy App

kubectl apply -f ../app/kubernetes/

Deploys the application Pods, Service, and the Ingress resource.

Final Verification (The Network Test)
Get ALB DNS: Run kubectl get ingress test-app-ingress. Wait for the ADDRESS field to populate with an ALB DNS name.

Test Connectivity: Use the DNS name to confirm public traffic successfully routes to the private container.

curl http://<ALB-DNS-NAME>

I recommend creating this file at the root of your project directory (~/testing-Project/README.md) before pushing to GitHub! Let me know if you need any other documentation.