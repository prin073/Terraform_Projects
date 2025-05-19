terraform {
  backend "s3" {
    bucket = "devops-directive-tf-state-prin073"
    key = "dev/terraform.tfstate" #keeping tfstate remotely
    region = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt = true
  }
}