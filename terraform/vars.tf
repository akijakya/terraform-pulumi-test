variable "ami" {
  type = map(string)

  default = {
    "eu-central-1" = "ami-0cc0a36f626a4fdf5"
  }
}

variable "instance_count" {
  default = "2"
}

variable "instance_tags" {
  type = list(string)
  default = ["akijakya-test", "akijakya-dev"]
}

variable "instance_scripts" {
  type = list(string)
  default = ["scripts/greeter-github.sh", "scripts/greeter-dockerhub.sh"]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "aws_region" {
  default = "eu-central-1"
}