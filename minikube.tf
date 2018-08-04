provider "aws" {
    profile = "minikube-provisioner"
    region  = "eu-west-1"
}

data "aws_caller_identity" "current" {}

data "aws_ami" "minikube" {
    most_recent = true
    name_regex  = "minikube"

    filter {
        name   = "owner-id"
        values = ["${data.aws_caller_identity.current.account_id}"]
    }
}

resource "aws_key_pair" "minikube" {
    public_key = "${file("minikube.pub")}"
}

data "http" "ip" {
  url = "http://icanhazip.com"
}

resource "aws_security_group" "allow_all" {
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [
            "${chomp(data.http.ip.body)}/32"
        ]       
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "minikube" {
    ami             = "${data.aws_ami.minikube.id}"
    instance_type   = "t2.micro"
    key_name        = "${aws_key_pair.minikube.key_name}"
    security_groups = ["${aws_security_group.allow_all.name}"]

    tags {
        Name = "minikube"
    }
}

output "host" {
    value = "${aws_instance.minikube.public_dns}"
}
