
#EC2 variables


variable "ami" {
  description = "Amazon macine image to use for ec2 instance"
  type = string
}

variable "instance_type" {
  description = "ec2 instance type"
  type = string
}

variable "instance_name" {
  description = "tag name for the instance"
}