# Accessing using IP wont work as we are using ALB. Use alb dns and access
output "alb_dns" {
  value = aws_lb.load_balancer.dns_name
}


output "instance1_public_ip" {
  value = aws_instance.web_app_instance1.public_ip
}

output "instance2_public_ip" {
  value = aws_instance.web_app_instance2.public_ip
}

# output "name_servers" {
#   value = aws_route53_zone.primary.name_servers
# }

output "db_instance_address" {
    value = aws_db_instance.rds_db.address 
}