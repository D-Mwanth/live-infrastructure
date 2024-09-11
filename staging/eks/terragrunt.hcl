terraform {
  source = "git@github.com:D-Mwanth/infrastructure-modules.git//eks?ref=eks-v0.0.1"
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
  eks_version = "1.30"
  env         = include.env.locals.env
  eks_name    = "env-cluster"
  subnet_ids  = dependency.vpc.outputs.private_subnets

  node_groups = {
    general = {
      capacity_type  = "ON_DEMAND"
      instance_types = ["t3.large"]
      scaling_config = {
        desired_size = 2
        max_size     = 8
        min_size     = 1
      }
    }
  }
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    private_subnets = ["subnet-1234", "subnet-5678"]
  }
}
