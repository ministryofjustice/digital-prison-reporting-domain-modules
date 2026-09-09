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
