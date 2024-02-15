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

variable "vpc_cidr_block" {
    type = string 
    default = "10.0.0.0/16"
    description = "CIDR block of the vpc"
}

variable "public_subnets_cidr_block" {
    type = list(any)
    default = ["10.0.0.0/20", "10.0.128.0/20"]
    description = "CIDR block for public subnet"
}

variable "private_subnets_cidr_block" {
    type = list(any)
    default = ["10.0.16.0/20", "10.0.144.0/20"]
    description = "CIDR Block for private subnet"
}

