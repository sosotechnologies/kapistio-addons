#################################################################
# AWS IAM User 1 - Admin User (Has Full AWS Access)
#################################################################
resource "aws_iam_user" "admin_user" {
  name = "${local.name}-eksadmin1"
  path = "/"
  force_destroy = true
  tags = local.common_tags
}

# Resource: Admin Access Policy - Attach it to admin user
resource "aws_iam_user_policy_attachment" "admin_user" {
  user       = aws_iam_user.admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


#################################################################
# Basic AWS IAM User 2 with user policy  (No AWSConsole Access)
#################################################################
resource "aws_iam_user" "basic_user" {
  name = "${local.name}-eksadmin2"
  path = "/"
  force_destroy = true
  tags = local.common_tags
}

## AWS IAM User Policy - EKS Dashboard Full Access
resource "aws_iam_user_policy" "basic_user_eks_policy" {
  name = "${local.name}-eks-dashboard-full-access-policy"
  user = aws_iam_user.basic_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:ListRoles",
          "eks:*",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
        #Resource = "${aws_eks_cluster.eks_cluster.arn}"
      },
    ]
  })
}

#################################################################
# AWS IAM eksadmin3 User 3
#################################################################
resource "aws_iam_user" "eksadmin_user" {
  name = "${local.name}-eksadmin3"
  path = "/"
  force_destroy = true
  tags = local.common_tags
}

#################################################################
# AWS IAM eksdeveloper1 user
#################################################################
resource "aws_iam_user" "eksdeveloper_user" {
  name = "${local.name}-eksdeveloper1"
  path = "/"
  force_destroy = true
  tags = local.common_tags
}


#################################################################
# AWS IAM eksreadonly1 user
#################################################################
resource "aws_iam_user" "eksreadonly_user" {
  name = "${local.name}-eksreadonly1"
  path = "/"
  force_destroy = true
  tags = local.common_tags
}