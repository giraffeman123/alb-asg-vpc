provider "aws" {
	region = "us-east-2"
  access_key = ""
  secret_key = ""
}

resource "aws_security_group" "demo_sg" {
  name        = "api"
  description = "Acceso por parte de maquina"

  ingress {
    description = "Acceso puerto 22 a maquina"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["XXX.XXX.X.XXX/32"]
  }

  ingress {
    description = "Acceso puerto 8080 a maquina"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["XXX.XXX.X.XXX/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  tags = {
    Name = "demo-sg"
  }
}

resource "aws_network_interface" "demo_eni" {
  security_groups = [aws_security_group.demo_sg.id]
  # <--- HAS TO BE ON THE SAME AVAILABILITY ZONE AS aws_ebs_volume.availability_zone --->
  subnet_id   = "ADD_HERE_SUBNET_WHERE_YOU_WANT_TO_PLACE_EC2_INSTANCE" 
  tags = {
    Name = "demo_network_interface"
  }
}

resource "aws_instance" "demo_instance" {
  # <--- CURRENT AMI IS Ubuntu Server 22.04 LTS [ami-024e6efaf93d85776] --->
  ami                    = "ami-024e6efaf93d85776"     
  instance_type          = "t2.micro" 

  # <--- CREATE KEY-PAIR IN AWS CONSOLE THEN REFERENCE NAME OF IT HERE --->
  key_name = "terraform-test"
  user_data = "${file("ec2-init-script.sh")}"
  tags = {
	  Name = "docker-node"			
  }

  network_interface {
    network_interface_id = aws_network_interface.demo_eni.id
    device_index         = 0
  }

  # <--- THIS IS THE ROOT DISK --->
  root_block_device {
    volume_size           = "8"
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
    tags = {
	    Name = "demo_root_ebs_block_device"			
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
	    Name = "demo_data_ebs_block_device"			
    }
    #... other arguments ...
  }  
  */
}

/*
# <--- [OPTIONAL] THIS IS AN EXTERNAL DATA DISK --->
resource "aws_ebs_volume" "demo_ebs_volume" {  
  # <--- HAS TO BE ON THE SAME AVAILABILITY ZONE AS aws_network_interface.subnet_id --->
  availability_zone = aws_instance.demo_instance.availability_zone
  size = 4 
  encrypted = false
  type = "gp2"
  tags = {
    Name = "demo_ebs_volume"
  }

}

resource "aws_volume_attachment" "demo_ebs_volume_attachment" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.demo_ebs_volume.id
  instance_id = aws_instance.demo_instance.id 
}
*/