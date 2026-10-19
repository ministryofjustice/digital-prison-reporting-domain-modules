variable "enable" {
  description = "When false, no alarms are created. Mirrors the enable pattern used across this repository."
  type        = bool
  default     = true
}

variable "alarm_name_prefix" {
  description = "Prefix applied to every alarm name. The alarm key is appended with a hyphen, e.g. '<prefix>-<key>' or '<prefix>-<key>-<suffix>' when alarm_name_suffix is set."
  type        = string
}

variable "alarm_name_suffix" {
  description = "Optional suffix appended after the alarm key, e.g. 'max-compaction-debt' produces '<prefix>-<key>-<suffix>'. Leave empty to produce '<prefix>-<key>'."
  type        = string
  default     = ""
}

variable "alarm_description_template" {
  description = "Template string for the alarm description. Use '%s' as a placeholder for the alarm key (domain name). Example: 'MaxCompactionDebt for domain %s exceeds threshold'."
  type        = string
  default     = "CloudWatch alarm for %s"
}

variable "metric_name" {
  description = "The name of the CloudWatch metric to alarm on."
  type        = string
}

variable "namespace" {
  description = "The CloudWatch metric namespace."
  type        = string
}

variable "statistic" {
  description = "The statistic to apply to the metric (e.g. Maximum, Average, Sum)."
  type        = string
  default     = "Maximum"
}

variable "period" {
  description = "The period in seconds over which the statistic is applied."
  type        = number
  default     = 86400
}

variable "comparison_operator" {
  description = "The arithmetic operation used when comparing the statistic to the threshold (e.g. GreaterThanThreshold)."
  type        = string
  default     = "GreaterThanThreshold"
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = number
  default     = 1
}

variable "treat_missing_data" {
  description = "How to treat missing data points (notBreaching, breaching, ignore, missing)."
  type        = string
  default     = "notBreaching"
}

variable "thresholds" {
  description = "Map of alarm key (e.g. domain name) to numeric threshold. One alarm is created per entry."
  type        = map(number)
}

variable "dimensions" {
  description = "Map of alarm key to a map of CloudWatch dimension name/value pairs for that alarm instance."
  type        = map(map(string))
  default     = {}
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic to notify on ALARM and OK state transitions. Set to null to disable notifications."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags applied to each alarm."
  type        = map(string)
  default     = {}
}
