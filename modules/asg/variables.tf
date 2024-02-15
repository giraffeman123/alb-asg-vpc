variable "aws_region" {
    type = string
    default = "us-east-2"
}

variable "aws_access_key" {
    type = string 
    default = ""
}

variable "aws_secret_key" {
    type = string 
    default = ""
}

variable "environment" {
    type = string 
    default = "dev"
}

variable "application" {
    type = string 
    default = "merge-sort"
}

variable "vpc_id" {
    type = string 
    default = ""
}

variable "private_subnets_ids" {
    type = list(string)
    default = [""]
}

variable "alb_target_group_arn" {
    type = string 
    default = ""
}

variable "alb_sg_id" {
    type = string 
    default = ""
}

variable "ec2_ami_id" {
    type = string
    default = "ami-024e6efaf93d85776"
}

variable "ec2_instance_type" {
    type = string
    default = "t2.micro"
}

variable "ec2_key_name" {
    type = string
    default = "terraform-test"
}

