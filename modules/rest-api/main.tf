provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = var.vpc_id
  name        = "api"
  description = "Acceso por parte de maquina"

  dynamic "ingress" {
    for_each = var.ec2_sg_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks      
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  tags = {
    Name = "${var.environment}-ec2-sg"
  }
}

resource "aws_network_interface" "ec2_eni" {
  security_groups = [aws_security_group.ec2_sg.id]
  # <--- HAS TO BE ON THE SAME AVAILABILITY ZONE AS aws_ebs_volume.availability_zone --->
  subnet_id = element(var.public_subnets_ids, 0)
  # subnet_id   = "subnet-04b1e6eefb3ae1c78" 
  tags = {
    Name = "${var.environment}-ec2_network_interface"
  }
}

resource "aws_instance" "ec2_instance" {
  # <--- CURRENT AMI IS Ubuntu Server 22.04 LTS [ami-024e6efaf93d85776] --->
  ami                    = var.ec2_ami_id    
  instance_type          = var.ec2_instance_type 

  # <--- CREATE KEY-PAIR IN AWS CONSOLE THEN REFERENCE NAME OF IT HERE --->
  key_name = var.ec2_key_name
  user_data = "${file("${path.module}/${var.ec2_user_data_filepath}")}"
  tags = {
	  Name = "${var.environment}-docker-node"			
  }

  network_interface {
    network_interface_id = aws_network_interface.ec2_eni.id
    device_index         = 0
  }

  # <--- THIS IS THE ROOT DISK --->
  root_block_device {
    volume_size           = "8"
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
    tags = {
	    Name = "${var.environment}-demo_root_ebs_block_device"			
    }
  }

  # <--- [OPTIONAL] THIS IS AN EXTERNAL DATA DISK --->
  /*
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 1
    volume_type = "gp2"    
    encrypted = false
    delete_on_termination = true
    tags = {
	    Name = "${var.environment}-demo_data_ebs_block_device"			
    }
    #... other arguments ...
  }  
  */
}

/*
# <--- [OPTIONAL] THIS IS AN EXTERNAL DATA DISK --->
resource "aws_ebs_volume" "demo_ebs_volume" {  
  # <--- HAS TO BE ON THE SAME AVAILABILITY ZONE AS aws_network_interface.subnet_id --->
  availability_zone = aws_instance.ec2_instance.availability_zone
  size = 4 
  encrypted = false
  type = "gp2"
  tags = {
    Name = "${var.environment}-demo_ebs_volume"
  }

}

resource "aws_volume_attachment" "demo_ebs_volume_attachment" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.demo_ebs_volume.id
  instance_id = aws_instance.ec2_instance.id 
}
*/