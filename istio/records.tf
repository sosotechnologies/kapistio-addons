provider "aws" {
  region = "us-east-1" # Change as needed
}

# Create hosted zones for each environment
resource "aws_route53_zone" "dev" {
  name = "dev.globalwealthorder.com"
}

resource "aws_route53_zone" "stag" {
  name = "stag.globalwealthorder.com"
}

resource "aws_route53_zone" "prod" {
  name = "prod.globalwealthorder.com"
}

# Load Balancer DNS Name
variable "load_balancer_dns_name" {
  description = "The DNS name of the Istio ingress load balancer"
  type        = string
  default     = "k8s-istioing-istioing-02c45aaad3-7f4188698cbeaadd.elb.us-east-1.amazonaws.com" # Replace with your load balancer DNS name
}

# Create CNAME records for applications in dev, stag, and prod
resource "aws_route53_record" "dev_argocd" {
  zone_id = aws_route53_zone.dev.id
  name    = "argocd.dev.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

resource "aws_route53_record" "dev_keycloak" {
  zone_id = aws_route53_zone.dev.id
  name    = "keycloak.dev.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

resource "aws_route53_record" "dev_elastic" {
  zone_id = aws_route53_zone.dev.id
  name    = "elastic.dev.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

resource "aws_route53_record" "dev_kibana" {
  zone_id = aws_route53_zone.dev.id
  name    = "kibana.dev.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

resource "aws_route53_record" "dev_longhorn" {
  zone_id = aws_route53_zone.dev.id
  name    = "longhorn.dev.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

# Repeat for stag environment
resource "aws_route53_record" "stag_argocd" {
  zone_id = aws_route53_zone.stag.id
  name    = "argocd.stag.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

resource "aws_route53_record" "stag_keycloak" {
  zone_id = aws_route53_zone.stag.id
  name    = "keycloak.stag.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

resource "aws_route53_record" "stag_elastic" {
  zone_id = aws_route53_zone.stag.id
  name    = "elastic.stag.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

resource "aws_route53_record" "stag_kibana" {
  zone_id = aws_route53_zone.stag.id
  name    = "kibana.stag.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

resource "aws_route53_record" "stag_longhorn" {
  zone_id = aws_route53_zone.stag.id
  name    = "longhorn.stag.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

# Repeat for prod environment
resource "aws_route53_record" "prod_argocd" {
  zone_id = aws_route53_zone.prod.id
  name    = "argocd.prod.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

resource "aws_route53_record" "prod_keycloak" {
  zone_id = aws_route53_zone.prod.id
  name    = "keycloak.prod.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

resource "aws_route53_record" "prod_elastic" {
  zone_id = aws_route53_zone.prod.id
  name    = "elastic.prod.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

resource "aws_route53_record" "prod_kibana" {
  zone_id = aws_route53_zone.prod.id
  name    = "kibana.prod.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}

resource "aws_route53_record" "prod_longhorn" {
  zone_id = aws_route53_zone.prod.id
  name    = "longhorn.prod.globalwealthorder.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}
