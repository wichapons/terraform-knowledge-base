resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  security_groups    = var.security_groups

  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    for_each = var.access_logs != null ? [var.access_logs] : []
    content {
      bucket  = access_logs.value.bucket
      prefix  = access_logs.value.prefix
      enabled = access_logs.value.enabled
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_lb_target_group" "this" {
  count = length(var.target_groups)

  name     = var.target_groups[count.index].name
  port     = var.target_groups[count.index].port
  protocol = var.target_groups[count.index].protocol
  vpc_id   = var.vpc_id

  target_type = var.target_groups[count.index].target_type

  dynamic "health_check" {
    for_each = var.target_groups[count.index].health_check != null ? [var.target_groups[count.index].health_check] : []
    content {
      enabled             = health_check.value.enabled
      healthy_threshold   = health_check.value.healthy_threshold
      interval            = health_check.value.interval
      matcher             = health_check.value.matcher
      path                = health_check.value.path
      port                = health_check.value.port
      protocol            = health_check.value.protocol
      timeout             = health_check.value.timeout
      unhealthy_threshold = health_check.value.unhealthy_threshold
    }
  }

  dynamic "stickiness" {
    for_each = var.target_groups[count.index].stickiness != null ? [var.target_groups[count.index].stickiness] : []
    content {
      type            = stickiness.value.type
      cookie_duration = stickiness.value.cookie_duration
      enabled         = stickiness.value.enabled
    }
  }

  tags = merge(var.tags, {
    Name = var.target_groups[count.index].name
  })
}

resource "aws_lb_target_group_attachment" "this" {
  count = length(var.target_attachments)

  target_group_arn = aws_lb_target_group.this[var.target_attachments[count.index].target_group_index].arn
  target_id        = var.target_attachments[count.index].target_id
  port             = var.target_attachments[count.index].port
}

resource "aws_lb_listener" "this" {
  count = length(var.listeners)

  load_balancer_arn = aws_lb.this.arn
  port              = var.listeners[count.index].port
  protocol          = var.listeners[count.index].protocol

  dynamic "default_action" {
    for_each = [var.listeners[count.index].default_action]
    content {
      type             = default_action.value.type
      target_group_arn = default_action.value.target_group_arn != null ? default_action.value.target_group_arn : aws_lb_target_group.this[default_action.value.target_group_index].arn

      dynamic "forward" {
        for_each = default_action.value.type == "forward" && default_action.value.forward != null ? [default_action.value.forward] : []
        content {
          dynamic "target_group" {
            for_each = forward.value.target_groups
            content {
              arn    = target_group.value.arn != null ? target_group.value.arn : aws_lb_target_group.this[target_group.value.target_group_index].arn
              weight = target_group.value.weight
            }
          }

          dynamic "stickiness" {
            for_each = forward.value.stickiness != null ? [forward.value.stickiness] : []
            content {
              enabled  = stickiness.value.enabled
              duration = stickiness.value.duration
            }
          }
        }
      }
    }
  }

  tags = var.tags
}
