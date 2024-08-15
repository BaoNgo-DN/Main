
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.0"
    }
  }

  # backend block specifies where and how the Terraform state file is stored.
  backend "s3" {
    bucket = "devops-recipe-app-tf-state-baongo-dn"
    # Defines the path within the S3 bucket to store the state file
    key     = "tf-state-setup"
    region  = "us-east-1"
    encrypt = true

    # Specifies a DynamoDB table used for state locking and consistency,
    # preventing simultaneous operations from multiple users or processes
    dynamodb_table = "devops-recipe-app-api-tf-lock"
  }
}

provider "aws" {
  region = "us-east-1"

  # define default tags that will be applied to all resources managed by this Terraform configuration
  default_tags {
    tags = {
      Environment = terraform.workspace
      Project     = var.project
      Contact     = var.contact
      ManageBy    = "Terraform/setup"
    }
  }
}



