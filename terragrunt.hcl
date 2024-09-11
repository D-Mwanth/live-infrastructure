# terraform state configuration
remote_state {
    backend = "s3"
    generate = {
        path = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }

    config = {
        bucket = "infra-bucket-by-daniel"
        key = "${path_relative_to_include()}/terraform.tfstate"
        region = "eu-north-1"
        encrypt = true
        dynamodb_table = "infra-terra-lock"
    }
}

generate "provider" {
    path = "provider.tf"
    if_exists = "overwrite_terragrunt"

    contents = <<EOF
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0"
        }
      }
    }

    provider "aws" {
        region = "eu-north-1"
    }
    EOF
}

