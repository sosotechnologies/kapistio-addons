module "helm_release_irsa" {
  source = "../modules/eks-irsa"

  chart            = "karpenter"
  chart_version    = "0.16.2"
  repository       = "https://charts.karpenter.sh/"
  description      = "Kubernetes Node Autoscaling: built for flexibility, performance, and simplicity"
  namespace        = "karpenter"
  create_namespace = true

  set = [
    {
      name  = "clusterName"
      value = module.eks.cluster_name
    },
    {
      name  = "clusterEndpoint"
      value = module.eks.cluster_endpoint
    },
    {
      name  = "aws.defaultInstanceProfile"
      value = aws_iam_instance_profile.karpenters.name
    },
    # Added Fargate provider for Karpenter
    {
      name  = "aws.fargateProfileSelector"
      value = "karpenter"
    }
  ]

  set_irsa_names = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]

  # IAM role for service account (IRSA)
  create_role = true
  role_name   = "karpenter-controller"
  role_policies = {
    karpenter = aws_iam_policy.karpenter_controller.arn
  }

  oidc_providers = {
    cafanwi = {
      provider_arn = module.eks.oidc_provider_arn
      service_account = "karpenter"
    }
  }

  tags = local.tags
}
