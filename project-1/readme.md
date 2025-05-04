https://www.youtube.com/watch?v=SLB_c_ayRMo&list=PPSV ==> Tutorial Terraform Course - Automate your AWS cloud infrastructure
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance ==> resource types can be found here along with providers

commands

terraform init ==> downloads the provider plugins from registry. Also downloads modules
terraform plan ==> compares tfstate with current configs and tells what going to be created if we run apply command
terraform apply ==> can be run w/o plan. it applies the plan created. It requires manual intervention
terraform apply -auto-approve ==> It doesn't require manual intervention
