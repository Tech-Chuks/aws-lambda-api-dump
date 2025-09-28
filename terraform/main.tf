terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Generate random suffix to avoid bucket name collisions
resource "random_id" "suffix" {
  byte_length = 4
}

# S3 bucket for Lambda results
resource "aws_s3_bucket" "lambda_results" {
  bucket        = "lambda-results-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "lambda-results-bucket"
    Environment = "dev"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.lambda_results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.lambda_results.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Default encryption (SSE-S3 with AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.lambda_results.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle: expire objects after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.lambda_results.id

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    filter {} # 👈 apply to all objects

    expiration {
      days = 30
    }
  }
}
