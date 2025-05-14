output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = module.upload_s3_bucket.bucket_arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket."
  value       = module.upload_s3_bucket.bucket_id
}
