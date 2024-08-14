# use AWS provider

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.0"
    }
  }

# backend block specifies where and how the Terraform state is stored.
  backend "s3" {
    bucket         = "devops-recipe-app-tf-state-baongo-dn"
    key            = "tf-state-setup"
    region         = "us-east-1"
    encrypt        = true

    # Specifies a DynamoDB table used for state locking and consistency,
    # preventing simultaneous operations from multiple users or processes
    dynamodb_table = "devops-recipe-app-api-tf-lock"
  }
}

#configures the AWS provider
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = terraform.workspace
      Project     = var.project
      Contact     = var.contact
      ManageBy    = "Terraform/setup"
    }
  }
}


# required_providers: Specifies the required version and source for the AWS provider.
# backend: Configures S3 as the backend to store the Terraform state file, using a DynamoDB table for state locking.
# provider: Sets the AWS region and applies default tags to resources for better management and identification.

