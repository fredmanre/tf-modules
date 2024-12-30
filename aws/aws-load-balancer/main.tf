locals {
  name = "${var.project_name}-${var.environment}"

  # We will define the protocol based on the lb type
  is_alb = var.load_balancer_type == "application"
  http_protocol = local.is_alb ? "HTTP" : "TCP"
  https_protocol = local.is_alb ? "HTTPS" : "TLS"
}

# Load Balancer creation
resource "aws_lb" "this" {
  name               = "${local.name}"
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = local.is_alb ? var.security_group_ids : null
  subnets           = var.subnets

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = local.is_alb ? var.enable_http2 : null

  tags = {
    Name        = "${local.name}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Target Groups
resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name        = "${local.name}-${each.key}-tg"
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = each.value.target_type

  dynamic "health_check" {
    for_each = each.value.health_check != null ? [each.value.health_check] : []
    content {
      enabled             = health_check.value.enabled
      healthy_threshold   = health_check.value.healthy_threshold
      interval            = health_check.value.interval
      matcher             = local.is_alb ? health_check.value.matcher : null
      path               = local.is_alb ? health_check.value.path : null
      port               = health_check.value.port
      protocol           = health_check.value.protocol
      timeout            = health_check.value.timeout
      unhealthy_threshold = health_check.value.unhealthy_threshold
    }
  }

  tags = {
    Name        = "${local.name}-${each.key}-tg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = local.http_protocol

  default_action {
    type = var.enable_ssl ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.enable_ssl ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.enable_ssl ? [] : [1]
      content {
        target_group {
          arn = values(aws_lb_target_group.this)[0].arn
        }
      }
    }
  }
}

# HTTPS Listener (if SSL is enable)
resource "aws_lb_listener" "https" {
  count = var.enable_ssl ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = local.https_protocol
  ssl_policy        = local.is_alb ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = values(aws_lb_target_group.this)[0].arn
  }
}