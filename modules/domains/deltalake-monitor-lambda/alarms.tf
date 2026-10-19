locals {
  domain_compaction_debt_thresholds = {
    for k, v in var.domain_schedules : k => coalesce(
      try(v.alert_thresholds.max_compaction_debt, null),
      var.default_max_compaction_debt_alert_threshold
    )
    if v.enabled && (
      try(v.alert_thresholds.max_compaction_debt, null) != null ||
      var.default_max_compaction_debt_alert_threshold != null
    )
  }

  domain_compaction_debt_dimensions = {
    for k in keys(local.domain_compaction_debt_thresholds) : k => {
      Domain  = k
      service = var.powertools_service_name
    }
  }

  effective_sns_topic_arn = var.slack_alerts_sns_topic_arn
}

module "max_compaction_debt_alarms" {
  source = "../../common/cloudwatch-domain-alarm"

  enable                     = var.enable
  alarm_name_prefix          = var.name
  alarm_name_suffix          = "max-compaction-debt"
  alarm_description_template = "MaxCompactionDebt for domain %s exceeds threshold"

  metric_name         = "MaxCompactionDebt"
  namespace           = "DPRAgentCustomMetrics"
  statistic           = "Maximum"
  period              = 86400
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  thresholds    = local.domain_compaction_debt_thresholds
  dimensions    = local.domain_compaction_debt_dimensions
  sns_topic_arn = local.effective_sns_topic_arn

  tags = merge(var.tags, { alarm_type = "max-compaction-debt" })
}

moved {
  from = aws_cloudwatch_metric_alarm.max_compaction_debt
  to   = module.max_compaction_debt_alarms.aws_cloudwatch_metric_alarm.this
}
