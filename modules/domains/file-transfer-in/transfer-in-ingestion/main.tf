# Each prefix in the S3 landing bucket needs to trigger the antivirus check lambda
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  # bucket = aws_s3_bucket.storage[0].id
  bucket = var.antivirus_trigger_bucket_arn # Might need to be id

  lambda_function {
    lambda_function_arn = var.antivirus_check_lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.bucket_prefix
  }

  depends_on = [var.antivirus_check_lambda_arn]
}