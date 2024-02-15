provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "template_file" "ec2_user_data" {
    template = "${file("${path.module}/${var.ec2_user_data_filepath}")}"
    vars = {
        app_port = 80
    }  
}

# Creating Security Group for EC2
resource "aws_security_group" "app_sg" {
    vpc_id = var.vpc_id
    name        = "app-sg-${var.application}-${var.environment}"
    description = "Security Group for ${var.application}-${var.environment}"    
    
    ingress {
        description = "HTTP port"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = ["${var.alb_sg_id}"]                    
    }
    
    # Outbound Rules
    # Internet access to anywhere
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# resource "aws_iam_instance_profile" "instance_profile" {
#   name = "${var.environment}-${var.application}-instance_profile"

#   role = var.iam_role
# }

resource "aws_launch_template" "app_lt" {
    name_prefix = "lt-${var.environment}-${var.application}"
    image_id = var.ec2_ami_id
    instance_type = var.ec2_instance_type
    key_name = var.ec2_key_name

    #   iam_instance_profile {
    #     name = "${var.environment}-${var.application}-instance_profile"
    #   }

    network_interfaces {
        associate_public_ip_address = true
        security_groups = [ "${aws_security_group.app_sg.id}" ]
    }

    #user_data = "${file("${path.module}/${var.ec2_user_data_filepath}")}"
    user_data = "${base64encode(data.template_file.ec2_user_data.rendered)}"
}

resource "aws_autoscaling_group" "app_asg" {
    name = "${aws_launch_template.app_lt.name}-asg"
    min_size = 2
    desired_capacity = 3
    max_size = 4
    vpc_zone_identifier = var.private_subnets_ids

    launch_template {
        id = aws_launch_template.app_lt.id
        version = aws_launch_template.app_lt.latest_version
    }

    lifecycle {
        ignore_changes = [load_balancers, target_group_arns]
    }

    tag {
        key                 = "Name"
        value               = "asg-${var.application}-${var.environment}"
        propagate_at_launch = true
    }    
}

resource "aws_autoscaling_policy" "cpu_scaling_policy" {
    name = "${var.environment}-${var.application}-cpu-scaling-policy"
    policy_type = "TargetTrackingScaling"
    estimated_instance_warmup = 20
    autoscaling_group_name = aws_autoscaling_group.app_asg.name

    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }

        target_value = 60
    }
}


resource "aws_autoscaling_attachment" "app_asg_attachment" {
    autoscaling_group_name = aws_autoscaling_group.app_asg.name
    lb_target_group_arn = var.alb_target_group_arn
}

