variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "raw_bucket_prefix" {
  type    = string
  default = "assignment-raw-data"
}

variable "report_bucket_prefix" {
  type    = string
  default = "assignment-reports"
}

variable "ecr_repo_name" {
  type    = string
  default = "assignment-pipeline"
}
