# 🚀 Secure EKS Cluster Deployment (Cloud Network Engineer Project)

**Project Owner:** Jose Armando Arroyo Rangel | **Role Focus:** Cloud Networking & IaC

## ✨ Description

This project provisions a production-grade Amazon EKS (Elastic Kubernetes Service) cluster and its complete networking stack using Terraform. The architecture adheres to critical security and DevOps best practices, making it a robust platform for modern containerized microservices.

### 🎯 Core Objectives Demonstrated:

| Objective | Focus Area | 
| ----- | ----- | 
| **Network Isolation** | Worker Nodes are segregated into private subnets, accessible only via a dedicated Load Balancer. | 
| **Infrastructure as Code (IaC)** | Full environment setup (VPC, EKS, IAM, Load Balancer Controller) defined, managed, and versioned via **Terraform**. | 
| **Secure Ingress** | Traffic enters via a public **Application Load Balancer (ALB)** and routes securely to private Kubernetes Pods. | 
| **Operational Excellence** | Includes a ready-to-run `buildspec.yml` for automated CI/CD deployment via AWS CodePipeline/CodeBuild. | 
| **Troubleshooting** | The project setup forces and resolves complex EKS IAM token and VPC endpoint access issues. | 

## 🗺️ Architecture Topology

The infrastructure is designed for high availability across multiple Availability Zones, ensuring secure ingress and robust outbound connectivity.



| Component | Network Layer | Role | 
| ----- | ----- | ----- | 
| **ALB (Application Load Balancer)** | **Public Subnets** | Internet entry point, receives external traffic and routes to private Pod IPs. | 
| **NAT Gateway** | **Public Subnets** | Provides secure, isolated outbound internet access (for image pulls, updates) for resources in private subnets. | 
| **EKS Worker Nodes** | **Private Subnets** | Hosts the application containers securely, isolated from the public internet. | 

## 🛠️ Resources Utilized

| Category | Resources/Tools | 
| ----- | ----- | 
| **Cloud** | AWS EKS, AWS VPC, AWS ECR, AWS IAM | 
| **IaC/Orchestration** | **Terraform** (`helm`, `kubernetes` providers), Kubernetes $\text{Ingress}$, $\text{Service}$, $\text{Deployment}$ | 
| **Automation** | Docker, `buildspec.yml` (CodeBuild standard), $\text{AWS}$ $\text{CLI}$ | 

---

## ⚡ Quick Start Guide: Deployment Steps

Run these commands from the **`terraform/`** directory after cloning the repository.

### Phase 1: Deploy Infrastructure (Terraform)

| Step | Command | Notes | 
| ----- | ----- | ----- | 
| **1. Prerequisites** | `aws configure` | Ensure AWS CLI is authenticated. **Manually create the S3 bucket and DynamoDB table** defined in `versions.tf`. | 
| **2. Initialize** | `terraform init` | Downloads modules and sets up the remote state. | 
| **3. Apply** | `terraform apply --auto-approve` | Provisions the entire VPC, EKS Cluster, and Worker Nodes. (This step takes the longest). | 

### Phase 2: Configure Access & Deploy Application

Once the infrastructure is deployed, run these commands to gain administrative access and launch the containerized application.

| Step | Command | Description | 
| ----- | ----- | ----- | 
| **1. Configure Access** | `aws eks update-kubeconfig --region us-east-1 --name jsarroyo-eks-testing` | Updates your local `~/.kube/config` to enable IAM authentication. |
| **2. Patch Auth (CRITICAL)** | `kubectl apply --validate=false -f ../app/patch.yaml` | **Fixes EKS IAM access gap** by patching the `aws-auth` ConfigMap to grant your IAM role `system:masters` permissions. |
| **3. Verify Nodes** | `kubectl get nodes` | Confirms successful authentication and should show your worker nodes as `Ready`. |
| **4. ECR Push** | (Manual) | Build your Docker image, tag it with your ECR URI and a tag (e.g., `v1.0.0`), and push it to the registry. |
| **5. Deploy App** | `kubectl apply -f ../app/kubernetes/` | Deploys the application Pods (3 replicas), Service, and Ingress. |

### ✅ Final Network Verification

1.  **Get ALB DNS:** Monitor the Ingress status for the DNS name.
    ```bash
    kubectl get ingress test-app-ingress
    ```

2.  **Test Connectivity:** Use the ALB DNS name to confirm the secure, end-to-end traffic flow.
    ```bash
    curl http://<ALB-DNS-NAME>
    ```

---
**Expected Result:** A response from a containerized Pod running in a **private subnet**.
