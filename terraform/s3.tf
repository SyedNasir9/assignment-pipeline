resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "raw" {
  bucket        = "${var.raw_bucket_prefix}-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name = "raw-data-bucket"
  }
}

resource "aws_s3_bucket" "reports" {
  bucket        = "${var.report_bucket_prefix}-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name = "reports-bucket"
  }
}
