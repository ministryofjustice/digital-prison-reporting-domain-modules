# tflint-ignore-file: terraform_required_version, terraform_required_providers
# Maintenance Pipeline Step Function
module "maintenance_pipeline" {
  source = "../../step_function"

  enable_step_function = var.setup_maintenance_pipeline
  step_function_name   = var.maintenance_pipeline_name

  step_function_execution_role_arn = var.step_function_execution_role_arn

  definition = jsonencode(
    {
      "Comment" : "Maintenance Pipeline Step Function",
      "StartAt" : "Stop Glue Streaming Job",
      "States" : {
        "Stop Glue Streaming Job" : {
          "Type" : "Task",
          "Resource" : "arn:aws:states:::glue:startJobRun.sync",
          "Parameters" : {
            "JobName" : var.glue_stop_glue_instance_job,
            "Arguments" : {
              "--dpr.stop.glue.instance.job.name" : var.glue_reporting_hub_cdc_jobname
            }
          },
          "Next" : "Run Compaction Job on Structured Zone"
        },
        "Maintenance" : {
          "Type" : "Parallel",
          "InputPath" : "$",
          "OutputPath" : "$",
          "ResultPath" : "$.ParallelResultPath",
          "Next" : "Archive Raw Data",
          "Branches" : [
            {
              "StartAt" : "Run Compaction Job on Structured Zone",
              "States" : {
                "Run Compaction Job on Structured Zone" : {
                  "Type" : "Task",
                  "Resource" : "arn:aws:states:::glue:startJobRun.sync",
                  "Parameters" : {
                    "JobName" : var.glue_maintenance_compaction_job,
                    "Arguments" : {
                      "--dpr.maintenance.root.path" : var.s3_structured_path,
                      "--dpr.config.s3.bucket" : var.s3_glue_bucket_id,
                      "--dpr.config.key" : var.domain
                    },
                    "NumberOfWorkers" : var.compaction_structured_num_workers,
                    "WorkerType" : var.compaction_structured_worker_type
                  },
                  "Next" : "Run Vacuum Job on Structured Zone"
                },
                "Run Vacuum Job on Structured Zone" : {
                  "Type" : "Task",
                  "Resource" : "arn:aws:states:::glue:startJobRun.sync",
                  "Parameters" : {
                    "JobName" : var.glue_maintenance_retention_job,
                    "Arguments" : {
                      "--dpr.maintenance.root.path" : var.s3_structured_path,
                      "--dpr.config.s3.bucket" : var.s3_glue_bucket_id,
                      "--dpr.config.key" : var.domain
                    },
                    "NumberOfWorkers" : var.retention_structured_num_workers,
                    "WorkerType" : var.retention_structured_worker_type
                  },
                  "End" : true
                }
              }
            },
            {
              "StartAt" : "Run Compaction Job on Curated Zone",
              "States" : {
                "Run Compaction Job on Curated Zone" : {
                  "Type" : "Task",
                  "Resource" : "arn:aws:states:::glue:startJobRun.sync",
                  "Parameters" : {
                    "JobName" : var.glue_maintenance_compaction_job,
                    "Arguments" : {
                      "--dpr.maintenance.root.path" : var.s3_curated_path,
                      "--dpr.config.s3.bucket" : var.s3_glue_bucket_id,
                      "--dpr.config.key" : var.domain
                    },
                    "NumberOfWorkers" : var.compaction_curated_num_workers,
                    "WorkerType" : var.compaction_curated_worker_type
                  },
                  "Next" : "Run Vacuum Job on Curated Zone"
                },
                "Run Vacuum Job on Curated Zone" : {
                  "Type" : "Task",
                  "Resource" : "arn:aws:states:::glue:startJobRun.sync",
                  "Parameters" : {
                    "JobName" : var.glue_maintenance_retention_job,
                    "Arguments" : {
                      "--dpr.maintenance.root.path" : var.s3_curated_path,
                      "--dpr.config.s3.bucket" : var.s3_glue_bucket_id,
                      "--dpr.config.key" : var.domain
                    },
                    "NumberOfWorkers" : var.retention_curated_num_workers,
                    "WorkerType" : var.retention_curated_worker_type
                  },
                  "End" : true
                }
              }
            }
          ]
        },
        "Start Glue Streaming Job" : {
          "Type" : "Task",
          "Resource" : "arn:aws:states:::glue:startJobRun",
          "Parameters" : {
            "JobName" : var.glue_reporting_hub_cdc_jobname,
            "Arguments" : {
              "--dpr.config.s3.bucket" : var.s3_glue_bucket_id,
              "--dpr.config.key" : var.domain
            }
          },
          "End" : true
        }
      }
    }
  )

  tags = var.tags

}