# Resource: AWS IAM Role - EKS Developer User
resource "aws_iam_role" "eks_developer_role" {
  name = "${local.name}-eks-developer-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""  # Empty Sid, optional, but can be removed for clarity
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
    ]
  })

  # Inline policy to grant necessary permissions for EKS Developer
  inline_policy {
    name = "eks-developer-access-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "eks:DescribeNodegroup",
            "eks:ListNodegroups",
            "eks:DescribeCluster",
            "eks:ListClusters",
            "eks:AccessKubernetesApi",
            "eks:ListUpdates",
            "eks:ListFargateProfiles",
            "eks:ListIdentityProviderConfigs",
            "eks:ListAddons",
            "eks:DescribeAddonVersions",
            "eks:DescribeUpdate",
            "eks:DescribeIdentityProviderConfig",
            "eks:DescribeAddon",
            "ssm:GetParameter",            # Access for SSM parameter retrieval
            "iam:PassRole",                # Allows developers to pass IAM roles (e.g., for EKS service account roles)
            "logs:DescribeLogStreams",     # Read access to CloudWatch logs (helpful for troubleshooting)
            "logs:GetLogEvents"            # Access to retrieve log events
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action   = [
            "ec2:DescribeInstances",        # Allows read-only access to EC2 instances (relevant for troubleshooting)
            "ec2:DescribeSubnets",          # View subnets associated with EKS cluster
            "ec2:DescribeSecurityGroups",   # View security groups
            "ec2:DescribeVpcs",             # View VPCs relevant to EKS
            "elasticloadbalancing:DescribeLoadBalancers"  # Useful for troubleshooting ELBs associated with EKS
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  # Tags block for resource tagging
  tags = {
    tag-key = "${local.name}-eks-developer-role"
  }
}

# # OPTIONAL: Attach managed policies to the role as needed
# resource "aws_iam_role_policy_attachment" "eks-developrole-s3fullaccess" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#   role       = aws_iam_role.eks_developer_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks-developrole-dynamodbfullaccess" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
#   role       = aws_iam_role.eks_developer_role.name
# }
