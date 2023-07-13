resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  
  website {
    index_document = var.index_document
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  # Public access is granted to buckets and objects through access control lists (ACLs), bucket policies, access point policies, or all. 
  # In order to ensure that public access to all your S3 buckets and objects is blocked, turn on Block all public access. 
  # These settings apply only to this bucket and its access points. 
  # AWS recommends that you turn on Block all public access, but before applying any of these settings, ensure that your applications will work correctly without public access. 
  # If you require some level of public access to your buckets or objects within, you can customize the individual settings below to suit your specific storage use cases.
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  #Versioning is a means of keeping multiple variants of an object in the same bucket. You can use versioning to preserve, retrieve, and restore every version of every object stored in your Amazon S3 bucket. 
  # With versioning, you can easily recover from both unintended user actions and application failures.
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  # Control ownership of objects written to this bucket from other AWS accounts and the use of access control lists (ACLs). 
  # Object ownership determines who can specify access to objects.
  # When ACLs are enabled and can be used to grant access to this bucket and its objects. 
  # If new objects written to this bucket specify the bucket-owner-full-control canned ACL, they are owned by the bucket owner. 
  # Otherwise, they are owned by the object writer.

  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  # Grant basic read/write permissions to other AWS accounts.
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.bucket.id
  acl    = var.acl_permissions
}

resource "aws_s3_bucket_cors_configuration" "cors_configuration" {
  # The CORS configuration, written in JSON, defines a way for client web applications that are loaded in one domain to interact with resources in a different domain.
  bucket = aws_s3_bucket.bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "POST", "PUT", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

# S3 objects. We have 2 folders where we upload the files and the zip file with python packages
resource "aws_s3_object" "uploaded" {
  bucket     = var.bucket_name
  key        = "uploaded/"            # Here we upload the MP4 file which will be converted into MP3 later on.
  acl        = var.acl_permissions
  depends_on = [aws_s3_bucket.bucket, aws_s3_bucket_ownership_controls.ownership, aws_s3_bucket_public_access_block.example, aws_s3_bucket_acl.example]
}

resource "aws_s3_object" "processed" {
  bucket     = var.bucket_name
  key        = "processed/"           # After Lambda procesessing the MP4 file into MP3, it stores the file here.  
  acl        = var.acl_permissions
  depends_on = [aws_s3_bucket.bucket, aws_s3_bucket_ownership_controls.ownership, aws_s3_bucket_public_access_block.example, aws_s3_bucket_acl.example]
}

resource "aws_s3_object" "package" {
  bucket     = var.bucket_name
  key        = "lambda_layer.zip"     # We have packaged the moviepy.editor, downloaded localy and uploaded here. 
  source     = local.zip_file_path
  depends_on = [aws_s3_bucket.bucket, aws_s3_bucket_ownership_controls.ownership, aws_s3_bucket_public_access_block.example, aws_s3_bucket_acl.example]
}

locals {
  zip_file_path = "path/to/zmypackage.zip"
}

output "bucket_name" {
  value       = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "bucket" {
  value = var.bucket_name
}