variable "name" {
  type        = string
  description = "The name of the lambda"
}

variable "enable" {
  type        = bool
  description = "Whether to enable the lambda related resources or not"
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository hosting the container image"
  type        = string
}

variable "image_version" {
  description = "The version of the image in the ECR repo to deploy in the Lambda"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for Lambda deployment"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the Lambda"
  type        = list(string)
}

variable "output_bucket_name" {
  description = "The name of the bucket where files passing the antivirus check are moved to"
  type        = string
}

variable "quarantine_bucket_name" {
  description = "he name of the bucket where files failing the antivirus check are moved to"
  type        = string
}

variable "log_retention_in_days" {
  description = "Log retention in number of days."
  type        = number
  default     = 7
}

variable "memory_size" {
  description = "Amount of memory to allocate to the lambda function."
  type        = number
  default     = 2048
}

variable "ephemeral_storage_size" {
  description = "Lambda Function Ephemeral Storage in /tmp. Min 512 MB and the Max 10240 MB"
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Value for the max number of seconds the lambda function will run."
  type        = number
  default     = 20
}

variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1"
  type        = number
  default     = -1
}

variable "policies" {
  description = "Additional IAM policies to attach to the lambda's IAM role."
  type        = list(any)
  default     = []
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) Key-value map of resource tags."
}
