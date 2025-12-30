output "raw_bucket" {
  value = aws_s3_bucket.raw.bucket
}

output "report_bucket" {
  value = aws_s3_bucket.reports.bucket
}

output "ecr_repo_uri" {
  value = aws_ecr_repository.app.repository_url
}

output "ecs_cluster" {
  value = aws_ecs_cluster.cluster.id
}
