provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Creating Security Group for ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id
  name        = "alb-sg-${var.application}-${var.environment}"
  description = "Security Group for ALB targeting ${var.application}-${var.environment}"    

  dynamic "ingress" {
      for_each = var.alb_sg_ingress_rules
      content {
          description = ingress.value.description
          from_port   = ingress.value.from_port
          to_port     = ingress.value.to_port
          protocol    = ingress.value.protocol
          cidr_blocks = ingress.value.cidr_blocks                  
      }
  }

  # Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "alb" {
    name = "alb-${var.application}-${var.environment}"    
    internal = false
    load_balancer_type = "application"

    subnets = var.public_subnets_ids
    security_groups = ["${aws_security_group.alb_sg.id}"]

    tags = {
      Name = "alb-${var.application}-${var.environment}"
    }    
}

resource "aws_alb_target_group" "alb_tg" {
    name_prefix = "alb-tg"
    vpc_id      = var.vpc_id
    port        = 80
    protocol    = "HTTP"
    target_type = "instance"

    health_check {
      path = "/api"
      port = 80
      protocol = "HTTP"
      interval = 30
      timeout  = 3
      healthy_threshold = 2
      unhealthy_threshold = 2
    }

    load_balancing_algorithm_type = "round_robin"

    tags = {
      Name = "alb-tg-${var.application}-${var.environment}"
    }      
}

resource "aws_alb_listener" "alb_listener" {
    load_balancer_arn = aws_alb.alb.arn
    port = 80
    protocol = "HTTP"

    default_action {
      target_group_arn = aws_alb_target_group.alb_tg.arn
      type = "forward"
    }
}