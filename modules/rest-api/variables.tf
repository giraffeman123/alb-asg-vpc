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

variable "vpc_id" {
    type = string 
    default = ""
}

variable "public_subnets_ids" {
    type = list(string)
    default = [""]
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

variable "ec2_sg_ingress_rules" {
    type = map(object({
        description = string
        from_port = number
        to_port = number
        protocol = string
        cidr_blocks = list(string)
    }))
    default = {
        "http port" = {
            description = "HTTP port"
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]      
        },        
        "ssh port" = {
            description = "SSH port"
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }        
    }
}