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
  description = "Amazon macine image to use for ec2 instance"
  type = string
  default = "ami-084568db4383264d4" #ubuntu
}

variable "instance_type" {

  description = "ec2 instance type"
  type = string
  default = "t2.micro"
  
}


#S3 Variables

variable "bucket_name" {
  description = "name of s3 bucket for app data"
  type = string
}

#RDS variables

variable "db_name" {
  description = "Name of DB"
  type = string
}

variable "db_user" {
  description = "username for DB"
  type = string
}

variable "db_pass" {
  description = "Password for DB"
  # sensitive = true
  type = string
}

variable "db_engine" {
  description = "db engine"
  type = string
  default = "mysql"
}

variable "db_engine_version" {
  description = "db engine version"
  type = string
  default = "8.0"
}

variable "db_instance_class" {
  description = "db instance class"
  type = string
  default = "db.t3.micro"
}