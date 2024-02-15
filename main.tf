module "my_vpc" {
  source = "./modules/vpc"
  aws_region = var.aws_region
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
  environment = var.environment
}

module "api_alb" {
  source = "./modules/alb"
  aws_region = var.aws_region
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
  environment = var.environment
  application = var.application
  vpc_id = module.my_vpc.vpc_id
  public_subnets_ids = module.my_vpc.public_subnets_ids  
}

module "api_asg" {
  source = "./modules/asg"
  aws_region = var.aws_region
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
  environment = var.environment
  application = var.application  
  vpc_id = module.my_vpc.vpc_id
  private_subnets_ids = module.my_vpc.private_subnets_ids
  alb_target_group_arn = module.api_alb.alb_target_group_arn
  alb_sg_id = module.api_alb.alb_sg_id
  ec2_ami_id = "ami-024e6efaf93d85776"
  ec2_instance_type = "t2.micro"  
  ec2_key_name = "terraform-test"
}