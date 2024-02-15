output "alb_dns_name" {
  description = "LoadBalancer dns name"
  value = aws_alb.alb.dns_name
}


output "alb_target_group_arn" {
  description = "ALB Target Group arn"
  value = aws_alb_target_group.alb_tg.arn
}

output "alb_sg_id" {
  description = "ALB Security Group Id"
  value = aws_security_group.alb_sg.id
}