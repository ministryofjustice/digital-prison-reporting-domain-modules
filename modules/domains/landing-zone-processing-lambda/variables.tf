variable "enable" {
  type        = bool
  description = "Whether to enable the lambda related resources or not"
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

variable "output_bucket_name" {
  description = "The name of the bucket where converted files are moved to"
  type        = string
}

variable "schema_registry_bucket_name" {
  description = "The name of the bucket where converted files are moved to"
  type        = string
}

variable "violations_bucket_name" {
  description = "The name of the bucket where files are moved to when they are classified as violations"
  type        = string
}

variable "violations_path" {
  description = "The path in the violations bucket where violations files are moved to, i.e. the prefix in the violations bucket where files classed as violations are moved to"
  type        = string
}

variable "csv_charset" {
  description = "The charset of the input CSV files"
  type        = string
  default     = "UTF-8"
}

variable "number_of_csv_header_rows_to_skip" {
  description = "The number of rows to skip at the start of the CSV file, e.g. 1 to skip a 1 line header"
  type        = number
  default     = 0
}

variable "log_csv" {
  description = "Whether to log all lines of the CSV file during landing zone processing"
  type        = bool
  default     = false
}

variable "lambda_handler" {
  description = "Notification Lambda Handler"
  type        = string
  default     = "uk.gov.justice.digital.hmpps.landingzoneprocessing.LandingZoneProcessingLambda::handleRequest"
}

variable "lambda_runtime" {
  description = "Lambda Runtime"
  type        = string
  default     = "java21"
}

variable "policies" {
  description = "A List of IAM Policies to apply to the lambda"
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
  default     = 60
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
