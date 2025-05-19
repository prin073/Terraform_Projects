terraform {

    #################################################
    # ASSUMES S3 BUCKET AND DYNAMO DB ALREADY EXISTS
    # SEE aws-backend/main.tf
    #AWS_PROFILE=terraform-course terraform init
    #################################################

   #Backend config (terraform { backend "s3" { ... } }) is evaluated before the rest of the Terraform code. 
   #The backend code doesn't know about your provider config. Therefore, you must export credentials via environment variables.
   #command to run AWS_PROFILE=terraform-course terraform init
   #After backend s3bucket and dynamo db is created running AWS_PROFILE=terraform-course terraform init will copy the local tfsatte file
   #and upload it to s3 bucket
   backend "s3" {
    bucket = "devops-directive-tf-state-prin073"
    key = "dev/terraform.tfstate" #keeping tfstate remotely
    region = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt = true
  }

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.97.0"
    }
  }
}

provider "aws" {

    profile = "terraform-course"
    region = "us-east-1"
  
}