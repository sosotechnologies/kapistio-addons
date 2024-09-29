# Resource: AWS IAM Role - EKS Read-Only User
resource "aws_iam_role" "eks_readonly_role" {
  name = "${local.name}-eks-readonly-role"

  # Assume role policy block
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
    ]
  })

  tags = {
    tag-key = "${local.name}-eks-readonly-role"
  }
}

# Move the inline policy to a separate resource
resource "aws_iam_role_policy" "eks_readonly_role_policy" {
  name = "eks-readonly-access-policy"
  role = aws_iam_role.eks_readonly_role.id # Attach to the created role

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "iam:ListRoles",
          "ssm:GetParameter",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "eks:ListUpdates",
          "eks:ListFargateProfiles",
          "eks:ListIdentityProviderConfigs",
          "eks:ListAddons",
          "eks:DescribeAddonVersions"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
