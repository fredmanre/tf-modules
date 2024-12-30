variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "task_definition_arn" {
  description = "Task definition RNA"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnets for the service"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the service"
  type        = list(string)
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "ecs_service_type" {
  description = "Service type (FARGATE, EC2)"
  type = string
  default = "EC2"
}

# Variables para el balanceador de carga
variable "enable_load_balancer" {
  description = "Indicates whether the service should use a load balancer"
  type        = bool
  default     = false
}

variable "target_group_arn" {
  description = "ARN of target group (required if enable_load_balancer = true)"
  type        = string
  default     = null
}

variable "container_name" {
  description = "Name of the load balancer container"
  type        = string
  default     = null
}

variable "container_port" {
  description = "Port of the load balancer container"
  type        = number
  default     = null
}

# Variables para Service Discovery
variable "enable_service_discovery" {
  description = "Enable service discovery"
  type        = bool
  default     = false
}

variable "namespace_id" {
  description = "ID of the service discovery namespace (required if enable_service_discovery = true)"
  type        = string
  default     = null
}

variable "dns_ttl" {
  description = "TTL for service discovery DNS records"
  type        = number
  default     = 10
}

# Variables para Auto Scaling
variable "enable_auto_scaling" {
  description = "Enable auto scaling for service"
  type        = bool
  default     = false
}

variable "auto_scaling_config" {
  description = "Configuration for auto scaling"
  type = object({
    min_capacity       = number
    max_capacity       = number
    cpu_threshold      = number
    memory_threshold   = number
    scale_in_cooldown  = number
    scale_out_cooldown = number
  })
  default = {
    min_capacity       = 1
    max_capacity       = 4
    cpu_threshold      = 75
    memory_threshold   = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}