variable "environment" {
  description = "Deployment environment (swv, staging , production)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "container_definitions" {
  description = "Container definition in json format"
  type        = string
}

variable "task_cpu" {
  description = "CPU assigned units"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "MB memory assigned"
  type        = number
  default     = 512
}

variable "operating_system_family" {
  description = "SO task (LINUX, WINDOWS_SERVER_2019_FULL, etc)"
  type        = string
  default     = "LINUX"
}

variable "cpu_architecture" {
  description = "CPU Architecture (X86_64, ARM64)"
  type        = string
  default     = "X86_64"
}

variable "task_role_arn" {
  description = "ARN of the IAM role to be used by the task to access AWS services"
  type        = string
}

variable "execution_role_arn" {
  description = "RNA of the IAM role that ECS will use to execute the task"
  type        = string
}

variable "network_mode" {
  description = "Network mode for the task (awsvpc, bridge, host, none)"
  type        = string
  default     = "awsvpc"
}

variable "volumes" {
  description = "Volume configuration for the task"
  type = list(object({
    name = string
    efs_volume_configuration = optional(object({
      file_system_id          = string
      root_directory          = optional(string)
      transit_encryption      = optional(string)
      transit_encryption_port = optional(number)
      authorization_config = optional(object({
        access_point_id = string
        iam            = string
      }))
    }))
    docker_volume_configuration = optional(object({
      autoprovision = optional(bool)
      driver        = optional(string)
      driver_opts   = optional(map(string))
      labels        = optional(map(string))
      scope         = optional(string)
    }))
  }))
  default = []
}

variable "proxy_configuration" {
  description = "App Mesh proxy configuration (if used)"
  type = object({
    type           = string
    container_name = string
    properties     = map(string)
  })
  default = null
}

variable "enable_ephemeral_storage" {
  description = "Enable additional ephemeral storage"
  type        = bool
  default     = false
}

variable "ephemeral_storage_size" {
  description = "Size of ephemeral storage in GB (only if enabled)"
  type        = number
  default     = 21
}

variable "tags" {
  description = "Additional tags for task definition"
  type        = map(string)
  default     = {}
}