//required_providers block is mandatory from tf 0.13+ versions
//This is a plugin which enables tf core to connect with the aws cloud provider(it provides APIs to connect to AWS)
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.97.0"
    }
  }
}

provider "aws" {

    region = "us-east-1"
    access_key = "AKIA5AFL4HHR672M3N6X"
    secret_key = "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"
  
}

//syntax resource "<provider_name>_<resource_type>" "<some_name>"

//below with create an ec2 instance. ami is image name of the server to be created(In this case I am creating an ubuntu instance)

resource "aws_instance" "my-first-server" {

    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"

    //not mandatory, it just adds a tag to the instance so that if we have multiple instances we can filter out it on AWS UI
    tags = {
        # Name="ubuntu"
    }
  
}