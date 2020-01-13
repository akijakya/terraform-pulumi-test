# Configure the AWS Provider: https://www.terraform.io/docs/providers/aws/index.html
# This time with credentials previously stored on the computer due to AWS CLI
# Terraform automatically searches for it when nothing is specified in its default directory
# If the credentials are in a different directory, you can specify with shared_credentials_file, as well as a custom profile

provider "aws" {
  profile                 = "default"
  region                  = "eu-central-1"
  # shared_credentials_file = "/Users/tf_user/.aws/creds"
}

# Connecting via ssh
# The pub file needed to be created in the desired directory first in the terminal with $ ssh-keygen -o
resource "aws_key_pair" "terraform-test" {
  key_name   = "terraform-test"
  public_key = file("~/Creds/terraform-test.pub")
}

# Creating security group with specified ports to open
resource "aws_security_group" "akijakya-greeter" {
  name        = "akijakya-greeter"
  description = "Sec group for akijakyas greeter terrafrom magic"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create 1 new AWS Instance. 
# For our EC2 instances, we specify an AMI for Ubuntu 
# (For eu-central-1 region: Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-0cc0a36f626a4fdf5 (64-bit x86) / ami-0f71209b1289bf95c (64-bit Arm))
# , and request a "t2.micro" instance so we qualify under the free tier.
resource "aws_instance" "prod" {
  ami           = "ami-0cc0a36f626a4fdf5"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.terraform-test.key_name

  # Copies the local hello-world folder to ~
  provisioner "file" {
    source      = "../hello-world"
    destination = "~"
    connection {
      type = "ssh"
      host = self.public_ip
      user = "ubuntu"
      private_key = file("~/Creds/terraform-test")
    }
  }

  # Runs the commands to start server
  provisioner "remote-exec" {
    script = "scripts/greeter.sh"
    connection {
      type = "ssh"
      host = self.public_ip
      user = "ubuntu"
      private_key = file("~/Creds/terraform-test")
    }
  }

  security_groups = [
    aws_security_group.akijakya-greeter.name
  ]

  tags = {
    Name = "akijakya-prod"
  }
}

# Create 2 another AWS instance but now with the usage of our vars.tf file and looping
resource "aws_instance" "dev" {
  count         = var.instance_count
  ami           = lookup(var.ami,var.aws_region)
  instance_type = var.instance_type
  key_name      = aws_key_pair.terraform-test.key_name
  user_data     = file(element(var.instance_scripts, count.index))  # The user_data only runs at instance launch time.

  security_groups = [
    aws_security_group.akijakya-greeter.name
  ]

  tags = {
    Name  = element(var.instance_tags, count.index)  # element syntax: element(list, index)
  }
}

# # Create a new load balancer
# resource "aws_elb" "elb" {
#   name               = "greeter-terraform-elb"
#   availability_zones = ["eu-central-1"]

#   # access_logs {
#   #   bucket        = "foo"
#   #   bucket_prefix = "bar"
#   #   interval      = 60
#   # }

#   listener {
#     instance_port     = 3000
#     instance_protocol = "http"
#     lb_port           = 80
#     lb_protocol       = "http"
#   }

#   listener {
#     instance_port      = 3000
#     instance_protocol  = "http"
#     lb_port            = 443
#     lb_protocol        = "https"
#     # ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
#   }

#   # health_check {
#   #   healthy_threshold   = 2
#   #   unhealthy_threshold = 2
#   #   timeout             = 3
#   #   target              = "HTTP:3000/"
#   #   interval            = 30
#   # }

#   instances                   = [aws_instance.prod.id, aws_instance.dev[0].id]
#   cross_zone_load_balancing   = true
#   idle_timeout                = 400
#   connection_draining         = true
#   connection_draining_timeout = 400

#   tags = {
#     Name = "greeter-terraform-elb"
#   }
# }