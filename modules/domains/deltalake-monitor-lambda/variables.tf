variable "enable" {
  type        = bool
  description = "Whether to enable the lambda related resources or not"
}

variable "region" {
  type        = string
  description = "Current AWS Region."
}

variable "account" {
  type        = string
  description = "AWS Account ID."
}

variable "name" {
  description = "Name for the Lambda"
  type        = string
}

variable "lambda_code_s3_bucket" {
  description = "Lambda Code Bucket"
  type        = string
}

variable "lambda_code_s3_key" {
  description = "Lambda Code Bucket Key"
  type        = string
}

variable "curated_bucket_name" {
  description = "The name of the curated bucket that this lambda reads Delta Lake table data/metadata from, e.g. to calculate table metrics"
  type        = string
}

variable "config_bucket_name" {
  description = "The name of the bucket containing domain config files"
  type        = string
}

variable "lambda_handler" {
  description = "Delta Lake Monitor Lambda Handler"
  type        = string
  default     = "hmpps_datahub_deltalake_monitor_lambda.main.lambda_handler"
}

variable "lambda_runtime" {
  description = "Lambda Runtime"
  type        = string
  default     = "python3.13"
}

variable "policies" {
  description = "A List of additional IAM Policies to apply to the lambda"
  type        = list(string)
  default     = []
}

variable "lambda_tracing" {
  description = "Lambda Tracing"
  type        = string
  default     = "Active"
}

variable "lambda_log_retention_in_days" {
  description = "Lambda log retention in number of days."
  type        = number
  default     = 7
}

variable "lambda_timeout_in_seconds" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 300
}

variable "memory_size_mb" {
  description = "Amount of memory to allocate to the lambda function."
  type        = number
  default     = 256
}

variable "subnet_ids" {
  description = "Lambda Subnet ID's"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Lambda Security Group ID's"
  type        = list(string)
  default     = []
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) Key-value map of resource tags."
}

variable "s3_list_cutoff_file_count" {
  description = "The maximum number of files the lambda will count when listing an S3 prefix for a table before stopping, to avoid spending too long listing prefixes with very many files."
  type        = number
}

variable "s3_list_time_cutoff_seconds" {
  description = "The maximum number of seconds the lambda will spend listing an S3 prefix for a table before stopping, to avoid spending too long listing prefixes with very many files."
  type        = number
}

variable "domain_schedules" {
  description = <<-EOT
    Map keyed by domain name, each entry configuring a scheduled invocation of the
    deltalake monitor lambda for that domain. The map key is used as the "domain" field
    of the invocation payload, e.g.:
      { "reference" = { schedule_expression = "rate(1 day)", target_size_bytes = 64000000 } }
    invokes the lambda with {"domain": "reference", "target_size_bytes": 64000000}.
  EOT
  type = map(object({
    schedule_expression = string
    target_size_bytes   = number
    enabled             = optional(bool, true)
    timezone            = optional(string, "UTC")
  }))
  default = {}

  validation {
    condition     = alltrue([for d in values(var.domain_schedules) : can(regex("^(rate|cron)\\(.+\\)$", d.schedule_expression))])
    error_message = "Each domain's schedule_expression must be a valid EventBridge rate(...) or cron(...) expression."
  }

  validation {
    condition     = alltrue([for d in values(var.domain_schedules) : d.target_size_bytes > 0])
    error_message = "target_size_bytes must be a positive number for every domain."
  }
}
