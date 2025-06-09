output "uploads_s3_bucket" {
  description = "The name of the uploads S3 bucket."
  value       = module.upload_s3_bucket.bucket_id
}

output "uploads_s3_bucket_arn" {
  description = "The ARN of the uploads S3 bucket."
  value       = module.upload_s3_bucket.bucket_arn
}

output "results_s3_bucket" {
  description = "The name of the results S3 bucket."
  value       = module.results_s3_bucket.bucket_id
}

output "results_s3_bucket_arn" {
  description = "The ARN of the results S3 bucket."
  value       = module.results_s3_bucket.bucket_arn

}