aws_region   = "ap-south-1"
project_name = "cloud-rds"
environment  = "dev"

vpc_name        = "cloud-vpc-vpc"
app_subnet_cidr = "10.0.3.0/24"

db_instance_class = "db.t3.micro"
allocated_storage = 20
db_name           = "appdb"
db_username       = "admin"
# db_password  — set via: export TF_VAR_db_password="YourSecurePassword123!"

multi_az            = false
deletion_protection = false
skip_final_snapshot = true
