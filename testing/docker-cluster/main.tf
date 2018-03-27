provider "aws" {
  region = "${var.aws_region}"
  version = "~> 1.10"
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "testing-swarm" {
  #name = "testing swarm"
  tags {
    Description = "Default security group for swarm nodes in suite testing"
    Name = "testing-swarm"
    ManagedBy = "terraform"
    Repo = "${var.repository}"
    Organisation = "${var.organisation}"
    Environment = "${var.environment}"
  }
  # TODO: limit to TCP and UDP ports ? for
  # internal network, and safe IPs for SSH.
  ingress {
    from_port = 0,
    to_port = 0,
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "testing-swarm-node" {
  tags {
    Description = "testing swarm node"
    Name = "testing-swarm-node"
    ManagedBy = "terraform"
    Repo = "${var.repository}"
    Organisation = "${var.organisation}"
    Environment = "${var.environment}"
  }
  ami = "${var.ami}"
  instance_type = "${var.machine}"
  vpc_security_group_ids = ["${aws_security_group.testing-swarm.id}"]
  root_block_device = {
    "delete_on_termination" = true
  }
  key_name = "${var.aws_key_name}"
  # TODO: setup a map in variables using data source "available".
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

output "testing-swarm-node-public-name" {
  value = "${aws_instance.testing-swarm-node.public_dns}"
}

output "testing-swarm-node-hostname" {
  value = "${aws_instance.testing-swarm-node.private_dns}"
}
