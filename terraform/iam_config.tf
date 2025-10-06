# terraform/iam_config.tf

# Data source to get the AWS Account ID dynamically
data "aws_caller_identity" "current" {}

# Creates the Kubernetes ConfigMap file content required to grant Admin role access
resource "local_file" "aws_auth_patch" {
  content = <<-EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Admin
      username: admin
      groups:
        - system:masters
EOT
  # Write the patch file outside the Terraform directory for kubectl access
  filename = "${path.module}/../app/patch.yaml"
  
  # Ensure the file is deleted upon destruction (Corrected lifecycle block)
  lifecycle {}
}