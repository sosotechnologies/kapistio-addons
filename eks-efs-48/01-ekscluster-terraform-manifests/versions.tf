# Terraform Settings Block
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.31"
     }
  }

  ## Backend and  statelock
  # backend "s3" {
  #   bucket = "terraform-on-aws-eks"
  #   key    = "dev/eks-cluster/terraform.tfstate"
  #   region = "us-east-1" 
 
  #   # For State Locking
  #   dynamodb_table = "dev-ekscluster"    
  # }  
}

provider "aws" {
  region = var.aws_region
}

# Datasource: 
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks_cluster.id
}

# Terraform Kubernetes Provider
provider "kubernetes" {
  host = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.cluster.token
}