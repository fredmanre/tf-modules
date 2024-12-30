locals {
  name = "${var.project_name}-${var.environment}"
}

# ECS Service
resource "aws_ecs_service" "this" {
  name            = local.name
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  desired_count   = var.desired_count
  launch_type     = var.ecs_service_type

  # Networking Configuration
  network_configuration {
    subnets          = var.private_subnets
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  # Load Balancer configuration (if the alb is enable)
  dynamic "load_balancer" {
    for_each = var.enable_load_balancer ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  # Discovery Service configuration (only if apply)
  dynamic "service_registries" {
    for_each = var.enable_service_discovery ? [1] : []
    content {
      registry_arn   = aws_service_discovery_service.this[0].arn
      container_name = var.container_name
      container_port = var.container_port
    }
  }

  # Deployment strategy
  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds = var.enable_load_balancer ? 60 : null

  # Enable the tags propagation
  enable_ecs_managed_tags = true
  propagate_tags         = "SERVICE"

  tags = {
    Name        = local.name
    Environment = var.environment
    Project     = var.project_name
  }
}

# Discovery Service (if it is enable)
resource "aws_service_discovery_service" "this" {
  count = var.enable_service_discovery ? 1 : 0

  name = local.name

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl  = var.dns_ttl
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# AutoScaling (if it is enabler)
resource "aws_appautoscaling_target" "this" {
  count = var.enable_auto_scaling ? 1 : 0

  max_capacity       = var.auto_scaling_config.max_capacity
  min_capacity       = var.auto_scaling_config.min_capacity
  resource_id        = "service/${split("/", var.cluster_id)[1]}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Autoscaling Policy for CPU
resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_auto_scaling ? 1 : 0

  name               = "${local.name}-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.auto_scaling_config.cpu_threshold
    scale_in_cooldown  = var.auto_scaling_config.scale_in_cooldown
    scale_out_cooldown = var.auto_scaling_config.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# Austoscaling Policy for Memory
resource "aws_appautoscaling_policy" "memory" {
  count = var.enable_auto_scaling ? 1 : 0

  name               = "${local.name}-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.auto_scaling_config.memory_threshold
    scale_in_cooldown  = var.auto_scaling_config.scale_in_cooldown
    scale_out_cooldown = var.auto_scaling_config.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}