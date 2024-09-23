# ### Create a Private Hosted Zone
# resource "aws_route53_zone" "private_zone" {
#   name = "private.globalwealthorder.com"  # Replace with your domain name
#   vpc {
#     vpc_id = module.vpc.vpc_id  # Link to your VPC
#   }
#   comment = "Private hosted zone for internal DNS resolution"
# }

# ### Create Public Hosted Zones for Your Subdomains
# resource "aws_route53_zone" "public_zone" {
#   name = "public.globalwealthorder.com"  # Main domain
# }

# resource "aws_route53_record" "argocd" {
#   zone_id = aws_route53_zone.public_zone.zone_id
#   name    = "argocd.public.globalwealthorder.com"
#   type    = "A"

#   alias {
#     name                   = module.eks.ingress_alb_dns  # Replace with your ALB DNS or NLB DNS from your ingress controller
#     zone_id                = module.eks.ingress_alb_zone_id  # This would be the hosted zone ID of your ALB/NLB
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "keycloak" {
#   zone_id = aws_route53_zone.public_zone.zone_id
#   name    = "keycloak.public.globalwealthorder.com"
#   type    = "A"

#   alias {
#     name                   = module.eks.ingress_alb_dns  # Same approach for other services
#     zone_id                = module.eks.ingress_alb_zone_id
#     evaluate_target_health = true
#   }
# }

# # Repeat for other services (elastic, kibana, longhorn)
