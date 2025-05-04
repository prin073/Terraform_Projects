Terraform AWS Automation Tutorial
This project demonstrates how to use Terraform to automate infrastructure provisioning on AWS.

📺 Source
```bash
https://www.youtube.com/watch?v=SLB_c_ayRMo&list=PPSV
```

🔧 Terraform Commands
```bash
Command	        Description
terraform init	Initializes the directory and downloads the necessary provider plugins and modules.
terraform plan	Shows the execution plan by comparing the current state with configuration files.
terraform apply	Applies the changes required to reach the desired state. Requires manual approval.
terraform apply -auto-approve	Applies changes without prompting for manual confirmation.
```

📚 AWS Resource Documentation
All available AWS resources and providers can be explored here:
👉 Terraform AWS Provider Documentation

📂 Project Structure
```bash
.
├── main.tf            # Main Terraform configuration
├── variables.tf       # Input variable definitions
├── outputs.tf         # Output values
└── README.md          # This file
```


🚀 Quick Start
```bash
terraform init
terraform plan
terraform apply         # or use -auto-approve for automation
```