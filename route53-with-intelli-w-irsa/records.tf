# resource "aws_route53_zone" "dev_zone" {
#   name = "dev.globalwealthorder.com"
# }

# resource "aws_route53_zone" "stag_zone" {
#   name = "stag.globalwealthorder.com"
# }

# resource "aws_route53_zone" "prod_zone" {
#   name = "prod.globalwealthorder.com"
# }

# # DNS Records for Services in Development
# resource "aws_route53_record" "argocd_dev" {
#   zone_id = aws_route53_zone.dev_zone.zone_id
#   name    = "argocd.dev.globalwealthorder.com"
#   type    = "A"
#   alias {
#     name                   = aws_lb.istio_ingress_dev.dns_name
#     zone_id                = aws_lb.istio_ingress_dev.zone_id
#     evaluate_target_health = false
#   }
#   depends_on = [module.eks, module.vpc]
# }

# resource "aws_route53_record" "keycloak_dev" {
#   zone_id = aws_route53_zone.dev_zone.zone_id
#   name    = "keycloak.dev.globalwealthorder.com"
#   type    = "A"
#   alias {
#     name                   = aws_lb.istio_ingress_dev.dns_name
#     zone_id                = aws_lb.istio_ingress_dev.zone_id
#     evaluate_target_health = false
#   }
#   depends_on = [module.eks, module.vpc]
# }

# # Additional records for stag and prod zones (replicated for other services)
# # Staging Example
# resource "aws_route53_record" "argocd_stag" {
#   zone_id = aws_route53_zone.stag_zone.zone_id
#   name    = "argocd.stag.globalwealthorder.com"
#   type    = "A"
#   alias {
#     name                   = aws_lb.istio_ingress_stag.dns_name
#     zone_id                = aws_lb.istio_ingress_stag.zone_id
#     evaluate_target_health = false
#   }
#   depends_on = [module.eks, module.vpc]
# }

# # Production Example
# resource "aws_route53_record" "argocd_prod" {
#   zone_id = aws_route53_zone.prod_zone.zone_id
#   name    = "argocd.prod.globalwealthorder.com"
#   type    = "A"
#   alias {
#     name                   = aws_lb.istio_ingress_prod.dns_name
#     zone_id                = aws_lb.istio_ingress_prod.zone_id
#     evaluate_target_health = false
#   }
#   depends_on = [module.eks, module.vpc]
# }


