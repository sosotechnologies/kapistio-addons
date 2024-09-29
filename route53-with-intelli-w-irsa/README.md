## 
It seems you've shared two important configuration files: main.tf for your infrastructure and Kubernetes setup, and route53.tf for DNS management. However, you have not provided the contents of route53.tf. Based on the provided main.tf, I'll point out a few key aspects and then suggest what may go into the route53.tf file, considering your Istio setup and the need for DNS subdomains.

Key Aspects of main.tf
1. Kubernetes and Helm Providers:

You have configured both Kubernetes and Helm providers to authenticate against your EKS cluster using AWS CLI credentials.

2. Istio Addon:

You are deploying Istio components (base, Istiod, ingress gateway) using Helm in specific namespaces (istio-system, istio-ingress).
The ingress gateway is set to use an internet-facing load balancer with relevant annotations.

3. EKS Cluster and Node Groups:

Your EKS cluster is set up with version 1.30 and manages node groups with auto-scaling handled by Karpenter.

4. Security Group Rules for Istio:

You’ve added security group rules for specific Istio ports (15012, 15017), which are essential for Istio's webhook and other services.

5. IRSA (IAM Roles for Service Accounts):

You’ve configured Karpenter and the AWS VPC CNI plugin with IRSA, allowing them to assume specific IAM roles.


### DNS and Route 53 Configuration in route53.tf
Since you're using subdomains (e.g., argocd.globalwealthorder.com, keycloak.globalwealthorder.com) in dev, stag, and prod environments, the route53.tf file would likely define hosted zones and records for your services. Here’s an outline of what the route53.tf might look like:

```sh
# Route 53 Hosted Zones for Subdomains
resource "aws_route53_zone" "dev_zone" {
  name = "dev.globalwealthorder.com"
}

resource "aws_route53_zone" "stag_zone" {
  name = "stag.globalwealthorder.com"
}

resource "aws_route53_zone" "prod_zone" {
  name = "prod.globalwealthorder.com"
}

# DNS Records for Services in Development
resource "aws_route53_record" "argocd_dev" {
  zone_id = aws_route53_zone.dev_zone.zone_id
  name    = "argocd.dev.globalwealthorder.com"
  type    = "A"
  alias {
    name                   = aws_lb.istio_ingress_dev.dns_name
    zone_id                = aws_lb.istio_ingress_dev.zone_id
    evaluate_target_health = false
  }
  depends_on = [module.eks, module.vpc]
}

resource "aws_route53_record" "keycloak_dev" {
  zone_id = aws_route53_zone.dev_zone.zone_id
  name    = "keycloak.dev.globalwealthorder.com"
  type    = "A"
  alias {
    name                   = aws_lb.istio_ingress_dev.dns_name
    zone_id                = aws_lb.istio_ingress_dev.zone_id
    evaluate_target_health = false
  }
  depends_on = [module.eks, module.vpc]
}

# Additional records for stag and prod zones (replicated for other services)
# Staging Example
resource "aws_route53_record" "argocd_stag" {
  zone_id = aws_route53_zone.stag_zone.zone_id
  name    = "argocd.stag.globalwealthorder.com"
  type    = "A"
  alias {
    name                   = aws_lb.istio_ingress_stag.dns_name
    zone_id                = aws_lb.istio_ingress_stag.zone_id
    evaluate_target_health = false
  }
  depends_on = [module.eks, module.vpc]
}

# Production Example
resource "aws_route53_record" "argocd_prod" {
  zone_id = aws_route53_zone.prod_zone.zone_id
  name    = "argocd.prod.globalwealthorder.com"
  type    = "A"
  alias {
    name                   = aws_lb.istio_ingress_prod.dns_name
    zone_id                = aws_lb.istio_ingress_prod.zone_id
    evaluate_target_health = false
  }
  depends_on = [module.eks, module.vpc]
}

# Other services like elastic, kibana, longhorn would follow the same pattern
```


Things to Note:
Load Balancers:

The aws_lb.istio_ingress_* refers to the load balancer provisioned by the Istio Ingress gateway in each environment (dev, stag, prod). You'll need to ensure these are properly provisioned in your main.tf.
Subdomains:

The DNS names for services such as argocd, keycloak, elastic, kibana, and longhorn should point to the respective load balancers created by the Istio ingress for each environment.
If you provide the route53.tf contents, I can refine the configuration further. Does this match your expectations for your setup?