variable "environment" {
  description = "environment deployment (dev, staging, prod, etc)"
  type        = string
}

variable "project_name" {
  description = "Project name."
  type        = string
}

variable "vpc_id" {
  description = "VPC id where the load balancer be deployed"
  type        = string
}

variable "subnets" {
  description = "subnet list for the load balancer."
  type        = list(string)
}

variable "security_group_ids" {
  description = "IDs security group that will be associate with the load balancer"
  type        = list(string)
}

variable "load_balancer_type" {
  description = "Load balancer type (application or network)"
  type        = string
  default     = "application"
  validation {
    condition     = contains(["application", "network"], var.load_balancer_type)
    error_message = "Load balancer type must be 'application' or 'network'."
  }
}

variable "internal" {
  description = "Wheter the LB will be intern (true) or public (false)"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "enable HTTP/2"
  type        = bool
  default     = true
}

variable "enable_ssl" {
  description = "Indicate if HTTPS/SSL should be setup"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of ACM certificate (required if enable_ssl = true)"
  type        = string
  default     = null
}

variable "target_groups" {
  description = "Target Group configuration"
  type = map(object({
    port                 = number
    protocol            = string
    target_type         = string
    health_check = object({
      enabled             = bool
      healthy_threshold   = number
      interval            = number
      matcher             = string
      path               = string
      port               = string
      protocol           = string
      timeout            = number
      unhealthy_threshold = number
    })
  }))
}