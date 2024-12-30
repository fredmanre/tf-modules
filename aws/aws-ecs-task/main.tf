locals {
  name = "${var.project_name}-${var.environment}"

  # Ephemeral storage configuration
  ephemeral_storage = var.enable_ephemeral_storage ? {
    size_in_gib = var.ephemeral_storage_size
  } : null
}

# Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = local.name
  requires_compatibilities = ["FARGATE"]
  network_mode            = var.network_mode
  cpu                     = var.task_cpu
  memory                  = var.task_memory

  # Roles IAM
  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  # Runtime platform
  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture       = var.cpu_architecture
  }

  # Containers
  container_definitions = var.container_definitions

  # Volumes
  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value.name

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = efs_volume_configuration.value.root_directory
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port

          dynamic "authorization_config" {
            for_each = efs_volume_configuration.value.authorization_config != null ? [efs_volume_configuration.value.authorization_config] : []
            content {
              access_point_id = authorization_config.value.access_point_id
              iam            = authorization_config.value.iam
            }
          }
        }
      }

      dynamic "docker_volume_configuration" {
        for_each = volume.value.docker_volume_configuration != null ? [volume.value.docker_volume_configuration] : []
        content {
          autoprovision = docker_volume_configuration.value.autoprovision
          driver        = docker_volume_configuration.value.driver
          driver_opts   = docker_volume_configuration.value.driver_opts
          labels        = docker_volume_configuration.value.labels
          scope         = docker_volume_configuration.value.scope
        }
      }
    }
  }

  # Proxy Configuration (App Mesh)
  dynamic "proxy_configuration" {
    for_each = var.proxy_configuration != null ? [var.proxy_configuration] : []
    content {
      type           = proxy_configuration.value.type
      container_name = proxy_configuration.value.container_name
      properties     = proxy_configuration.value.properties
    }
  }

  # Ephemeral storage
  dynamic "ephemeral_storage" {
    for_each = local.ephemeral_storage != null ? [local.ephemeral_storage] : []
    content {
      size_in_gib = ephemeral_storage.value.size_in_gib
    }
  }

  tags = merge(
    {
      Name        = local.name
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}
