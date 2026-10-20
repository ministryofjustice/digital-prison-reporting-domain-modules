# Per-domain EventBridge schedules that invoke the deltalake monitor lambda

locals {
  create_schedules = var.enable && length(var.domain_schedules) > 0
}

resource "aws_iam_role" "scheduler_invocation" {
  count = local.create_schedules ? 1 : 0

  name = "${var.name}-scheduler-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "scheduler.amazonaws.com" }
        Action    = "sts:AssumeRole"
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "scheduler_invoke_lambda" {
  count = local.create_schedules ? 1 : 0

  name = "${var.name}-scheduler-invoke-policy"
  role = aws_iam_role.scheduler_invocation[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = module.deltalake_monitor_lambda.lambda_function
      },
    ]
  })
}

module "deltalake_monitor_schedule" {
  source = "../../eventbridge_trigger"

  for_each = var.enable ? var.domain_schedules : {}

  create_eventbridge_schedule = true
  enable_eventbridge_schedule = each.value.enabled
  eventbridge_trigger_name    = "${var.name}-schedule-${each.key}"
  description                 = "Triggers the deltalake monitor lambda for domain ${each.key}"

  schedule_expression          = each.value.schedule_expression
  schedule_expression_timezone = each.value.timezone

  arn      = module.deltalake_monitor_lambda.lambda_function
  role_arn = aws_iam_role.scheduler_invocation[0].arn
  # Payload is: {"domain": <key>, "target_size_bytes": <value>}
  input = jsonencode({
    domain            = each.key
    target_size_bytes = each.value.target_size_bytes
  })
}
