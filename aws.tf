variable "aws_access_key"   { default = "" }
variable "aws_secret_key"   { default = "" }
variable "aws_region"       { default = "us-east-1"}
variable "aws_ami"          { default = "" }

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

resource "aws_key_pair" "xl-deploy" {
  key_name = "xld"
  public_key = "${file(\"ssh/xld.pub\")}"
}

resource "aws_security_group" "xl-deploy" {
    name = "xl-deploy"
    description = "Allow All inbound traffic on Ubuntu Ports"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port =  80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 4516
        to_port = 4516
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "xl-deploy" {
  instance_type = "m1.small"
  ami = "${var.aws_ami}"
  count = 1
  key_name = "${aws_key_pair.xl-deploy.key_name}"
  security_groups = ["${aws_security_group.xl-deploy.name}"]
  
}

output "addressess" {
  value = "${aws_instance.xl-deploy.public_dns}"
}
