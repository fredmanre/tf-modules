output "task_definition_arn" {
  description = "task definition ARN"
  value       = aws_ecs_task_definition.this.arn
}

output "task_definition_family" {
  description = "task definition Family"
  value       = aws_ecs_task_definition.this.family
}

output "task_definition_revision" {
  description = "Task Definition revision number"
  value       = aws_ecs_task_definition.this.revision
}

output "container_definitions" {
  description = "Container applied defintions"
  value       = aws_ecs_task_definition.this.container_definitions
}