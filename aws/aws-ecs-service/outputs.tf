output "service_id" {
  description = "ID del servicio ECS"
  value       = aws_ecs_service.this.id
}

output "service_name" {
  description = "ECS name"
  value       = aws_ecs_service.this.name
}

output "service_arn" {
  description = "ARN of ECS service"
  value       = aws_ecs_service.this.id
}

output "service_discovery_service_arn" {
  description = "Discovery Service ARN (if it is enable)"
  value       = var.enable_service_discovery ? aws_service_discovery_service.this[0].arn : null
}

output "autoscaling_target_resource_id" {
  description = "Autoscaling ID resource (if it is enable)"
  value       = var.enable_auto_scaling ? aws_appautoscaling_target.this[0].resource_id : null
}