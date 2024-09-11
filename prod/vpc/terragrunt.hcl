terraform {
  source = "git@github.com:D-Mwanth/infrastructure-modules.git//vpc?ref=vpc-v0.0.1"
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
  env             = include.env.locals.env
  azs             = ["eu-north-1a", "eu-north-1b"]
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]

  private_subnets_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/prod-env-cluster"  = "owned"
  }

  public_subnets_tags = {
    "kubernetes.io/role/elb"         = 1
    "kubernetes.io/cluster/prod-env-cluster" = "owned"
  }
}
