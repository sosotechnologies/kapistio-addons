terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
  }

    # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "xcite-terraform-state"
    key    = "dev/eks-efs/terraform.tfstate"
    region = "us-east-1" 
 
    # For State Locking
    # dynamodb_table = "xcite-terraform"    
  }  

}
