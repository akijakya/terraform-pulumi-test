# Configure the AWS Provider: https://www.terraform.io/docs/providers/aws/index.html
# This time with credentials previously stored on the computer due to AWS CLI
# Terraform automatically searches for it when nothing is specified in its default directory
# If the credentials are in a different directory, you can specify with shared_credentials_file, as well as a custom profile

provider "aws" {
  region                  = "eu-central-1"
  # shared_credentials_file = "/Users/tf_user/.aws/creds"
  # profile                 = "customprofile"
}

# Connecting via ssh
# The pub file needed to be created in the desired directory first in the terminal with $ ssh-keygen -o
resource "aws_key_pair" "terraform-test" {
  key_name   = "terraform-test"
  public_key = "${file("~/Creds/terraform-test.pub")}"
}

# Create 1 new AWS Instance. 
# For our EC2 instances, we specify an AMI for Ubuntu 
# (For eu-central-1 region: Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-0cc0a36f626a4fdf5 (64-bit x86) / ami-0f71209b1289bf95c (64-bit Arm))
# , and request a "t2.micro" instance so we qualify under the free tier.
resource "aws_instance" "production" {
  ami           = "ami-0cc0a36f626a4fdf5"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.terraform-test.key_name}"

  # Copies the local hello-world folder to ~/hello-world
  provisioner "file" {
    source      = "../hello-world"
    destination = "~/hello-world"
  }

  # Runs 
  provisioner "remote-exec" {
  script = "../greeter.sh"
}

  tags = {
    Name = "akijakya-prod"
  }
}

# Create 2 another AWS instance but now with the usage of our vars.tf file and looping
resource "aws_instance" "my-instance" {
  count         = "${var.instance_count}"
  ami           = "${lookup(var.ami,var.aws_region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.terraform-test.key_name}"
  user_data     = "${file("${element(var.instance_scripts, count.index)}")}"  # The user_data only runs at instance launch time.

  tags = {
    Name  = "${element(var.instance_tags, count.index)}"  # element syntax: element(list, index)
  }
}