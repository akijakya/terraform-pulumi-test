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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

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
resource "aws_instance" "greeter" {
  ami           = "ami-0cc0a36f626a4fdf5"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.terraform-test.key_name
  user_data     = file("./greeter-dockerhub.sh")

  security_groups = [
    aws_security_group.akijakya-greeter.name
  ]

  tags = {
    Name = "akijakya-greeter"
  }
}

output "instance_ips" {
  value = ["${aws_instance.greeter.*.public_ip}"]
}