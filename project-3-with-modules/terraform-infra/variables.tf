#All variables used across should be declared/defined in this file
#After that we can either pass the value of these defined variables
#either from command line, .tfvars file, TF_VAR_ env vars

#General Variables
variable "region" {
  description = "Default region for provider"
  type = string
  default = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile"
  type = string
  default = "terraform-course"
}

#EC2 variables


variable "ami" {
  default = "ami-084568db4383264d4" #ubuntu
}

variable "instance_type" {
  default = "t2.micro"
  
}


variable "instance_name" {
  default = "web-app"
}
