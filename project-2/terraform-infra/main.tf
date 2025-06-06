resource "aws_instance" "web_app_instance1" {
    ami = var.ami
    instance_type = var.instance_type
    security_groups = [ aws_security_group.sg.id ]
    key_name        = "ec2-key-pair"
    tags = {
      Name = "terraform-course-instance1"
    }
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello World 1" > index.html
        nohup python3 -m http.server 8080 --bind 0.0.0.0 &
    EOF
}

resource "aws_instance" "web_app_instance2" {
    ami = var.ami
    instance_type = var.instance_type
    security_groups = [ aws_security_group.sg.id ]
    key_name        = "ec2-key-pair"
    tags = {
      Name = "terraform-course-instance2"
    }
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello World 2" > index.html
        nohup python3 -m http.server 8080 --bind 0.0.0.0 &
    EOF
}

#data block will refernece exist resources

# Default VPC
data "aws_vpc" "default_vpc" {
  default = true
}

# Get all subnets in the default VPC
data "aws_subnets" "default_subnet" {
  filter {
    name="vpc-id" #should be vpc-id not any other name for default subnet filtering
    values = [ data.aws_vpc.default_vpc.id ]
  }
}

# Security Group: Clubbing all traffic under security_group block instead of sepaarte security_group_rule
resource "aws_security_group" "sg" {
  name = "instance-security-group"
  description = "Allow inbound traffic"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #allows all inbound IP
  }

  ingress {
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #allows all inbound IP
  }

  ingress {
    from_port         = 3306
    to_port           = 3306
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" # all protocol
    cidr_blocks = ["0.0.0.0/0"] #allows all inbound IP

  }
}

# # Ingress rule (HTTP 8080)
# resource "aws_security_group_rule" "allow_http_inbound" {
#   type = "ingress"
#   security_group_id = aws_security_group.sg.id
#   from_port = 8080
#   to_port = 8080
#   protocol = "tcp"
#   cidr_blocks = ["0.0.0.0/0"] #allows all inbound IP
# }

# resource "aws_security_group_rule" "allow_http_80" {
#   type              = "ingress"
#   security_group_id = aws_security_group.sg.id
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
# }


# resource "aws_security_group_rule" "allow_ssh_inbound" {
#   type = "ingress"
#   security_group_id = aws_security_group.sg.id
#   from_port = 22
#   to_port = 22
#   protocol = "tcp"
#   cidr_blocks = ["0.0.0.0/0"] #allows all inbound IP
# }

# # To allow access from command line or mysql workbench
# resource "aws_security_group_rule" "allow_mysql_inbound" {
#   type              = "ingress"
#   from_port         = 3306
#   to_port           = 3306
#   protocol          = "tcp"
#   security_group_id = aws_security_group.sg.id
#   cidr_blocks       = ["0.0.0.0/0"]
# }


# # Egress rule (Allow all)
# resource "aws_security_group_rule" "allow_http_outbound" {
#   type = "egress"
#   security_group_id = aws_security_group.sg.id
#   from_port = 0
#   to_port = 0
#   protocol = "-1" # all protocol
#   cidr_blocks = ["0.0.0.0/0"] #allows all inbound IP
# }

# Application Load Balancer
resource "aws_lb" "load_balancer" {
  name = "web-app-lb"
  load_balancer_type = "application"  #application or network
  subnets = data.aws_subnets.default_subnet.ids
  security_groups = [aws_security_group.sg.id]
}

resource "aws_lb_target_group" "lb_target_group" {
  name = "example-target-group"
  port = 8080
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default_vpc.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

# Attach EC2 Instances to Target Group
# This will allow LB to know where to send the traffic
resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.lb_target_group.arn
  target_id = aws_instance.web_app_instance1.id
  port = 8080
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.lb_target_group.arn
  target_id = aws_instance.web_app_instance2.id
  port = 8080
}


# Load Balancer Listener
resource "aws_lb_listener" "lb_listner" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}


# resource "aws_lb_listener" "lb_listner" {
#   load_balancer_arn = aws_lb.load_balancer.arn
#   port = 80
#   protocol = "HTTP"

#   #By default return a simple 404 page
#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "404: page not found"
#       status_code = 404
#     }
#   }
# }

# Listener Rule
# resource "aws_lb_listener_rule" "listner_rule" {
#   listener_arn = aws_lb_listener.lb_listner.arn

#   condition {
#     path_pattern {
#       values = [ "*" ]
#     }
#   }

#   action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.lb_target_group.arn
#   }
# }


#TODO: route 53 for dns so that we can type host name in browser and access it

# resource "aws_route53_zone" "primary" {
#   name="princekumar.infinityfreeapp.com"
  
# }

# resource "aws_route53_record" "root" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name = "princekumar.infinityfreeapp.com"
#   type = "A"
#   alias {
#     name = aws_lb.load_balancer.dns_name
#     zone_id = aws_lb.load_balancer.zone_id
#     evaluate_target_health = true
#   }
# }


# At last add name server from route 53 to your domain. ABove domain is not working so access the api using alb dns name

#RDS
resource "aws_db_instance" "rds_db" {
  allocated_storage    = 10
  db_name              = var.db_name
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  username             = var.db_user
  password             = var.db_pass
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible = true
}