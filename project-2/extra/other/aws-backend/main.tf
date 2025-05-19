


terraform {

    ########################################################
    #AFTER RUNNING TERRAFORM APPLY(WITH LOCAL BACKEND)
    #YOU WILL UNCOIMMENT THIS CODE THEN RERUN TARRAFORM INIT
    #TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
    ######################################################### 

#     backend "s3" {
#     bucket = "devops-directive-tf-state-prin073"
#     key = "dev/terraform.tfstate" #keeping tfstate remotely
#     region = "us-east-1"
#     dynamodb_table = "terraform-state-locking"
#     encrypt = true
#   }

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.97.0"
    }
  }
}
 

provider "aws" {
  region = "us-east-1"
  profile = "terraform-course"
}


resource "aws_s3_bucket" "terraform_state" {
  bucket = "devops-directive-tf-state-prin073" #bucket name. s3 bukcet names are globally unique across all AWS accounts. Once a name is taken by anyone, anywhere in the world, you cannot reuse it.
  force_destroy = true
  tags = {
    Name        = "terraform state bucket"
  }
  # This safety feature ensures that Terraform will refuse to destroy the resource, even if you run terraform destroy
  # lifecycle {
  #   prevent_destroy = true
  # }
}


#added to facilitate versioning of s3 bukcet being created above
resource "aws_s3_bucket_versioning" "name" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

#added to facilitate encryption of data at s3 bukcet for safety purpose
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" #Free with SSE-S3 (AES256): AWS doesn’t charge extra for this.
    }
  }
}

resource "aws_dynamodb_table" "terraform-locks" {
  name = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID" #partitionKey

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name  = "Terraform Lock Table"
  }
}