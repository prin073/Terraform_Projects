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
    profile = "princedev"
    region = "us-east-1"  
}

//syntax resource "<provider_name>_<resource_type>" "<some_name>"

//below with create an ec2 instance. ami is image name of the server to be created(In this case I am creating an ubuntu instance)

# resource "aws_instance" "my-first-server" {

#     ami = "ami-084568db4383264d4"
#     instance_type = "t2.micro"

#     //not mandatory, it just adds a tag to the instance so that if we have multiple instances we can filter out it on AWS UI
      //It adds a name corresponding to the instance on UI
#     tags = {
#         Name="ubuntu"
#     }
  
# }

//Note: tf doesn't execute blocks in order. Tf is smart enough to run the blocks which is needed first before running the dependent block
//each resource gets one Id assigned once it's created. Here aws_subnet needs aws_vpc id to create subnet

# resource "aws_vpc" "first-vpc" {
#     cidr_block = "10.0.0.0/16"

#     tags = {
#       Name = "production"
#     }
  
# }

# resource "aws_subnet" "subnet-1" {
#   vpc_id = aws_vpc.first-vpc.id  #once created by aws_vpc resource it will be fetched and used
#   cidr_block = "10.0.0.0/24"

#   tags = {
#     Name = "prod-subnet"
#   }

# }

#0. pre-requisite[Manual Step]: geneartae a key pair to ssh to EC2 instance created in step9 ==> search key pairs[ec2-key-pair.pem file]

//Recommended: 1 vpc per env
#1. Create VPC
resource "aws_vpc" "first-vpc" {

  cidr_block = "10.0.0.0/16" #10.0.0.0 to 10.0.255.255

  tags = {
    Name = "production"
  }
  
}

#2. Create Internet Gateway
  // To have a public IP and access the wbe-server through internet, we should have a Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.first-vpc.id

  tags = {
    Name = "first-igw"
  }
}

#3. Create Custom Route Table[To Allow Traffic from our subnet to get out to the internet]

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0" #send all traffic(IPs) to internet gateway. We can also specify an specific IP range(ex: 10.0.1.0/24)
    gateway_id = aws_internet_gateway.gw.id
  }

  //If you're using IPv6 and need an EIGW, then define it properly: resource "aws_egress_only_internet_gateway" and then reference it in route table
  # route {
  #   ipv6_cidr_block        = "::/0"
  #   egress_only_gateway_id = aws_internet_gateway.gw.id
  # }

  tags = {
    Name = "prod-route-table"
  }
}


#4. Create a  subnet
resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.first-vpc.id

  cidr_block = "10.0.0.0/24" #10.0.0.0 to 10.0.0.255
  availability_zone = "us-east-1a" #if not provided aws will assign a az.
  tags = {
    Name = "subnet-1"
  }
}

#5. Associate subnet with Route table: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
    //Please note that one of either subnet_id or gateway_id is required.

resource "aws_route_table_association" "route-table-association" {
  route_table_id = aws_route_table.prod-route-table.id
  subnet_id = aws_subnet.subnet-1.id  
}


#6. Create security group to allow port 22, 80, 443
resource "aws_security_group" "allow_web" {

  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.first-vpc.id

  #from-to is range of ports

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #specifci IP range can also be added
  }

   ingress {
    description = "HTTP"
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
  
}
#7. Create a network interface with an IP in the subnet that was created in step4
  //assigns a private IP address
  
# resource "aws_network_interface" "web-server-nic" {
#   subnet_id       = aws_subnet.subnet-1.id
#   private_ips     = ["10.0.0.50"]  #attach an IP address within the subnet range 10.0.0.0 - 10.0.0.255
#   security_groups = [aws_security_group.allow_web.id]
# }


#8. Assign an elastic IP to the network interface created in step7
  // EIP needs internet gateway & ec2 instance to be deployed first
  //assigns a public IP.
  //Static public IP (Elastic IP) remains fixed even across stop/start.

# resource "aws_eip" "prod-eip" {

#   domain                    = "vpc"
#   network_interface         = aws_network_interface.web-server-nic.id
#   associate_with_private_ip = "10.0.0.50"
#   depends_on = [ aws_internet_gateway.gw, aws_instance.web-server-instance ] # Ensure EC2 is created before associating EIP

# }



#9. Create Ubuntu EC2 instance and install/enable apache2
resource "aws_instance" "web-server-instance" {

  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a" #should be same as subnet
  key_name = "ec2-key-pair"

  //comment below if using step 7 & 8(this assigns a static private IP and ephemeral public IP, easy to deploy w/o worrying about network interfaces)
  subnet_id = aws_subnet.subnet-1.id
  associate_public_ip_address = true #remove step7 & 8 and use this instead[this uses default network interface]
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  # uncomment below if using step 7 & 8(custom NIC)
  # network_interface {
  #   device_index = 0   #eth0, eth1. attach nic to ec2
  #   network_interface_id = aws_network_interface.web-server-nic.id
  # }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo mkdir -p /var/www/html
              echo "your very first web server" > /var/www/html/index.html
              EOF


  tags = {
    Name = "web-server-instance"
  }
  
}

#To log into the console else always have to use tf state show command to know the IP of deployed server
#server_private_ip = "10.0.0.37"
# server_public_ip = "13.216.239.205"

output "server_public_ip" {

  value = aws_instance.web-server-instance.public_ip
  
}

output "server_private_ip" {

  value = aws_instance.web-server-instance.private_ip
  
}