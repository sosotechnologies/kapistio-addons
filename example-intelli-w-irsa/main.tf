provider "aws" {
  region = local.region
}

### added this for the sake of istio  ############
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
######### ########################################

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # cafanwi requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name       = basename(path.cwd)
  region     = "us-east-1"
  account_id = data.aws_caller_identity.current.account_id

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  ### added a second CIDR ###
  secondary_cidr = "10.1.0.0/16"
  ###############################

  #### added istio ####
  istio_chart_url     = "https://istio-release.storage.googleapis.com/charts"
  istio_chart_version = "1.20.2"
  #### added istio ####
  karpenter_tag_key = "karpenter.sh/discovery/${local.name}"

  tags = {
    Example    = local.name
    GithubRepo = "aws-ia/terraform-aws-eks-blueprints-addon"
  }
}

################################################################################
# EKS Blueprints Addon
################################################################################

# module "helm_release_only" {
#   source = "../modules/eks-irsa"

#   chart         = "metrics-server"
#   chart_version = "3.8.2"
#   repository    = "https://kubernetes-sigs.github.io/metrics-server/"
#   description   = "Metric server helm Chart deployment configuration"
#   namespace     = "kube-system"

#   values = [
#     <<-EOT
#       podDisruptionBudget:
#         maxUnavailable: 1
#       metrics:
#         enabled: true
#     EOT
#   ]

#   set = [
#     {
#       name  = "replicas"
#       value = 3
#     }
#   ]
# }

################################################################################
# Adding Istio to the Addons
################################################################################

resource "kubernetes_namespace_v1" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

module "eks_istio_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # This is required to expose Istio Ingress Gateway
  enable_aws_load_balancer_controller = true

  helm_releases = {
    istio-base = {
      chart         = "base"
      chart_version = local.istio_chart_version
      repository    = local.istio_chart_url
      name          = "istio-base"
      namespace     = kubernetes_namespace_v1.istio_system.metadata[0].name
    }

    istiod = {
      chart         = "istiod"
      chart_version = local.istio_chart_version
      repository    = local.istio_chart_url
      name          = "istiod"
      namespace     = kubernetes_namespace_v1.istio_system.metadata[0].name

      set = [
        {
          name  = "meshConfig.accessLogFile"
          value = "/dev/stdout"
        }
      ]
    }

    istio-ingress = {
      chart            = "gateway"
      chart_version    = local.istio_chart_version
      repository       = local.istio_chart_url
      name             = "istio-ingress"
      namespace        = "istio-ingress" # per https://github.com/istio/istio/blob/master/manifests/charts/gateways/istio-ingress/values.yaml#L2
      create_namespace = true

      values = [
        yamlencode(
          {
            labels = {
              istio = "ingressgateway"
            }
            service = {
              annotations = {
                "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
                "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
                "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
                "service.beta.kubernetes.io/aws-load-balancer-attributes"      = "load_balancing.cross_zone.enabled=true"
              }
            }
          }
        )
      ]
    }
  }

  tags = local.tags
}
#######
######
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
    }
  ]

  set_irsa_names = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  # # Equivalent to the following but the ARN is only known internally to the module
  # set = [{
  #   name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  #   value = iam_role_arn.cafanwi[0].arn
  # }]

  # IAM role for service account (IRSA)
  create_role = true
  role_name   = "karpenter-controller"
  role_policies = {
    karpenter = aws_iam_policy.karpenter_controller.arn
  }

  oidc_providers = {
    cafanwi = {
      provider_arn = module.eks.oidc_provider_arn
      # namespace is inherited from chart
      service_account = "karpenter"
    }
  }

  tags = local.tags
}

module "irsa_only" {
  source = "../modules/eks-irsa"

  # Disable helm release
  create_release = false

  # IAM role for service account (IRSA)
  create_role = true
  role_name   = "aws-vpc-cni-ipv4"
  role_policies = {
    AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  }

  oidc_providers = {
    cafanwi = {
      provider_arn    = module.eks.oidc_provider_arn
      namespace       = "kube-system"
      service_account = "aws-node"
    }
  }

  tags = local.tags
}

module "disabled" {
  source = "../modules/eks-irsa"

  create = false
}

################################################################################
# Supporting resources
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name                   = local.name
  cluster_version                = "1.30"
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with cafanwi module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have cafanwi tag in your account)
    (local.karpenter_tag_key) = local.name
  })
  #######  add rules for istio  ##################################
  node_security_group_additional_rules = {
    ingress_15017 = {
      description                   = "Cluster API - Istio Webhook namespace.sidecar-injector.istio.io"
      protocol                      = "TCP"
      from_port                     = 15017
      to_port                       = 15017
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_15012 = {
      description                   = "Cluster API to nodes ports/protocols"
      protocol                      = "TCP"
      from_port                     = 15012
      to_port                       = 15012
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
  ####### added  rules for istio above  #########################################
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  ### Added secondary CIDR ###
  secondary_cidr_blocks = [local.secondary_cidr]
  #############################
  azs             = local.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] #[for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = ["10.0.48.0/24", "10.0.49.0/24", "10.0.50.0/24"] #[for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  database_subnets     = ["10.0.77.0/24", "10.0.78.0/24", "10.0.79.0/24", "10.1.15.0/24"]  # added this subnet [100.0.1.0/24] for secondary cidr

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    (local.karpenter_tag_key) = local.name
  }

  tags = local.tags
}

resource "aws_iam_instance_profile" "karpenters" {
  name = "KarpenterNodeInstanceProfile-${local.name}"
  role = module.eks.eks_managed_node_groups["initial"].iam_role_name

  tags = local.tags
}

data "aws_iam_policy_document" "karpenter_controller" {
  statement {
    actions = [
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:CreateTags",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeSpotPriceHistory",
      "pricing:GetProducts",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:TerminateInstances",
      "ec2:DeleteLaunchTemplate",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/${local.karpenter_tag_key}"
      values   = [module.eks.cluster_name]
    }
  }

  statement {
    actions = ["ec2:RunInstances"]
    resources = [
      "arn:aws:ec2:*:${local.account_id}:launch-template/*",
      "arn:aws:ec2:*:${local.account_id}:security-group/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/${local.karpenter_tag_key}"
      values   = [module.eks.cluster_name]
    }
  }

  statement {
    actions = ["ec2:RunInstances"]
    resources = [
      "arn:aws:ec2:*::image/*",
      "arn:aws:ec2:*:${local.account_id}:instance/*",
      "arn:aws:ec2:*:${local.account_id}:spot-instances-request/*",
      "arn:aws:ec2:*:${local.account_id}:volume/*",
      "arn:aws:ec2:*:${local.account_id}:network-interface/*",
      "arn:aws:ec2:*:${local.account_id}:subnet/*",
    ]
  }

  statement {
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:*:*:parameter/aws/service/*"]
  }

  statement {
    actions   = ["iam:PassRole"]
    resources = [module.eks.eks_managed_node_groups["initial"].iam_role_arn]
  }
}

resource "aws_iam_policy" "karpenter_controller" {
  name_prefix = "Karpenter_Controller_Policy-"
  description = "Provides permissions to handle node termination events via the Node Termination Handler"
  policy      = data.aws_iam_policy_document.karpenter_controller.json

  tags = local.tags
}
