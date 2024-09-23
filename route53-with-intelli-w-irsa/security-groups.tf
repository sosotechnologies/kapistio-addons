# resource "aws_security_group" "custom_sg" {
#   name        = "${local.name}-custom-sg"
#   description = "Custom Security Group for Ports 8080 and 8088"
#   vpc_id      = module.vpc.vpc_id

#   # Ingress rule for port 8080
#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  # Allows access from anywhere
#   }

#   # Ingress rule for port 8088
#   ingress {
#     from_port   = 8088
#     to_port     = 8088
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  # Allows access from anywhere
#   }

#   # Egress rule to allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]  # Allows all outbound traffic
#   }

#   tags = local.tags
# }
