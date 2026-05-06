variable "project_id" {
  type        = string
  description = "(Required) Project Short ID that will be used for resources."
}

variable "env" {
  type        = string
  description = "(Required) The environment we are deploying into"
}

variable "account_id" {
  description = "AWS Account ID."
  type        = string
}

variable "script_file_version" {
  type        = string
  description = "The filename of the glue script, including version"
}

variable "create_compaction_job" {
  description = "Enable compaction job, True or False"
  type        = bool
  default     = false
}

variable "create_retention_job" {
  description = "Enable retention job, True or False"
  type        = bool
  default     = false
}

variable "create_compaction_job_role" {
  description = "(Optional) Create AWS IAM role associated with the compaction job."
  type        = bool
  default     = false
}

variable "create_retention_job_role" {
  description = "(Optional) Create AWS IAM role associated with the retention job."
  type        = bool
  default     = false
}

variable "compaction_job_name" {
  description = "Name of the Glue compaction job"
  type        = string
}

variable "retention_job_name" {
  description = "Name of the Glue retention job"
  type        = string
}

variable "compaction_job_short_name" {
  description = "Short name for the Glue compaction job"
  type        = string
}

variable "retention_job_short_name" {
  description = "Short name for the Glue retention job"
  type        = string
}

variable "glue_version" {
  type        = string
  default     = "5.0"
  description = "(Optional) The version of glue to use."
}

variable "create_sec_conf" {
  type        = bool
  default     = false
  description = "(Optional) Create AWS Glue Security Configuration associated with the job."
}

variable "temp_dir" {
  type        = string
  default     = null
  description = "(Optional) Specifies an Amazon S3 path to a bucket that can be used as a temporary directory for the job."
}

variable "spark_event_logs" {
  type        = string
  default     = null
  description = "(Optional) Specifies an Amazon S3 path to a bucket that can be used as a Spark Event Logs directory for the job."
}

variable "execution_class" {
  default     = "STANDARD"
  description = "Execution CLass STANDARD or FLEX"
  type        = string
}

variable "compaction_job_worker_type" {
  type        = string
  default     = "G.1X"
  description = "(Optional) The type of predefined worker that is allocated when a compaction job runs."

  validation {
    condition     = contains(["G.1X", "G.2X", "G.4X", "G.8X"], var.compaction_job_worker_type)
    error_message = "Accepts a value of G.1X, G.2X, G.4X or G.8X."
  }
}

variable "retention_job_worker_type" {
  type        = string
  default     = "G.1X"
  description = "(Optional) The type of predefined worker that is allocated when a retention job runs."

  validation {
    condition     = contains(["G.1X", "G.2X", "G.4X", "G.8X"], var.retention_job_worker_type)
    error_message = "Accepts a value of G.1X, G.2X, G.4X or G.8X."
  }
}

variable "s3_kms_arn" {
  type        = string
  default     = ""
  description = "(Optional) The ARN of the kMS Key associated to S3"
}

variable "account_region" {
  description = "Current AWS Region."
  default     = "eu-west-2"
  type        = string
}

variable "compaction_job_num_workers" {
  type        = number
  default     = 2
  description = "(Optional) The number of workers of a defined workerType that are allocated when a job runs."
}

variable "retention_job_num_workers" {
  type        = number
  default     = 2
  description = "(Optional) The number of workers of a defined workerType that are allocated when a job runs."
}

variable "max_concurrent_runs" {
  type        = number
  default     = 128
  description = "(Optional) The maximum number of concurrent runs allowed for a job."
}

variable "log_group_retention_in_days" {
  type        = number
  default     = 7
  description = "(Optional) The default number of days log events retained in the glue job log group."
}

variable "additional_secret_arns" {
  type        = list(string)
  default     = []
  description = "(Optional) The list of additional secrets this job needs access to."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) Key-value map of resource tags."
}

variable "glue_compaction_job_arguments" {
  type        = map(string)
  default     = {}
  description = "(Optional) Arguments for the compaction job"
}

variable "glue_retention_job_arguments" {
  type        = map(string)
  default     = {}
  description = "(Optional) Arguments for the retention job"
}

variable "enable_spark_ui" {
  type        = string
  default     = "true"
  description = "UI Enabled by default, override with False"
}
