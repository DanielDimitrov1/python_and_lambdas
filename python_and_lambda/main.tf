provider "aws" {
  region = var.region
}

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "4.65.0"
        }
    }
}


# Here I need to declare the following services
# 1. Cognito + IAM roles;
# 2. Route 53;
# 3. First Lambda   + Python script;
# 4. Second Lambda  + Python script;
# 5. S3 bucket;

module "s3" {
    source = "./modules/s3"
}
# 6. SQS;
# 7. CloudFront; 