# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.61.0"
     }
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "sosotoday"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = "us-east-1" 
 
    # dynamodb_table = "soso-dynamo1"    
  }  
}

# Terraform Provider Block
provider "aws" {
  region = var.aws_region
}