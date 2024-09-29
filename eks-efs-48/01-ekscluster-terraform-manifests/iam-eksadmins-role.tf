# Resource: AWS IAM Role - EKS Admin
resource "aws_iam_role" "eks_admin_role" {
  name = "${local.name}-eks-admin-role"

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
    tag-key = "${local.name}-eks-admin-role"
  }
}

# Move the inline policy to a separate resource
resource "aws_iam_role_policy" "eks_admin_role_policy" {
  name = "eks-full-access-policy"
  role = aws_iam_role.eks_admin_role.id # Attach to the created role

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "iam:ListRoles",
          "eks:*",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
