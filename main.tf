module "my_vpc" {
  source = "./modules/vpc"
  aws_region = var.aws_region
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
  environment = var.environment
}

module "rest_api" {
  source = "./modules/rest-api"
  aws_region = var.aws_region
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
  environment = var.environment  
  vpc_id = module.my_vpc.vpc_id
  public_subnets_ids = module.my_vpc.public_subnets_ids
  ec2_ami_id = "ami-024e6efaf93d85776"
  ec2_instance_type = "t2.micro"  
  ec2_key_name = "terraform-test"
}