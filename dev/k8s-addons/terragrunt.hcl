terraform {
  source = "git@github.com:D-Mwanth/infrastructure-modules.git//k8s-addons?ref=k8s-addons-v0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  env      = include.env.locals.env
  eks_name = dependency.eks.outputs.eks_name
  vpc_id = dependency.vpc.outputs.vpc_id
  cluster_autoscaler_helm_version = "9.28.0"
}

# Specify dependencies
dependency "eks" {
  config_path = "../eks"
  mock_outputs = {
    eks_name            = "env-cluster"
  }
}

# Input for the Load Balancer module in the next session
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-12345678"
  }
}

# Generate helm provider configurations
generate "helm_provider" {
  path      = "helm-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
data "aws_eks_cluster" "eks" {
    name = var.eks_name
}

data "aws_eks_cluster_auth" "eks" {
    name = var.eks_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.eks.token
  }
}
EOF
}
