output "load_balancer_arn" {
  description = "Load Balancer ARN"
  value       = aws_lb.this.arn
}

output "load_balancer_dns_name" {
  description = "Load Balancer DNS name"
  value       = aws_lb.this.dns_name
}

output "target_group_arns" {
  description = "Map of RNAs from the Target Groups created"
  value = {
    for k, v in aws_lb_target_group.this : k => v.arn
  }
}

output "http_listener_arn" {
  description = "HTTP listener ARN"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN (if enabled)"
  value       = var.enable_ssl ? aws_lb_listener.https[0].arn : null
}