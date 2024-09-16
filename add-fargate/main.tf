locals {
  name = "the-cluster-name" # Define the name of your cluster
  tags = {
    Environment = "dev"
    Project     = "fargate-integration"
  }
}
# Add a Fargate profile for Karpenter-managed pods


resource "aws_eks_fargate_profile" "karpenter_fargate_profile" {
  cluster_name = module.eks.cluster_name
  fargate_profile_name = "${local.name}-karpenter-fargate"

  pod_execution_role_arn = aws_iam_role.fargate_execution_role.arn

  # Add a selector to run pods from the karpenter namespace on Fargate
  selector {
    namespace = "karpenter"

    labels = {
      environment = "fargate"
    }
  }

  subnet_ids = module.vpc.private_subnets

  tags = local.tags
}

# IAM role for Fargate pod execution
resource "aws_iam_role" "fargate_execution_role" {
  name = "${local.name}-fargate-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

# Attach the AmazonEKSFargatePodExecutionRole policy to the Fargate execution role
resource "aws_iam_role_policy_attachment" "fargate_execution_role_policy" {
  role = aws_iam_role.fargate_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRole"
}
