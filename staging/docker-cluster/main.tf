provider "aws" {
  region = "${var.aws_region}"
  version = "~> 1.10"
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "staging-swarm" {
  #name = "${var.environment} swarm"
  tags {
    Description = "Default security group for swarm nodes in ${var.environment}"
    Name = "${var.environment}-swarm"
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

resource "aws_instance" "staging-swarm-node" {
  count = "${var.swarm-cluster-zones}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  ami = "${var.swarm-node-image[count.index]}"
  instance_type = "${var.swarm-node-type[count.index]}"
  vpc_security_group_ids = ["${aws_security_group.staging-swarm.id}"]
  root_block_device = {
    "delete_on_termination" = true
  }
  key_name = "${var.aws_key_name}"
  tags {
    Description = "${var.environment} swarm node"
    Name = "${var.environment}-swarm-node-${count.index}"
    ManagedBy = "terraform"
    Repo = "${var.repository}"
    Organisation = "${var.organisation}"
    Environment = "${var.environment}"
  }
}

output "staging-swarm-public-name" {
  value = "${aws_instance.staging-swarm-node.*.public_dns[0]}"
}

output "staging-swarm-nodes-public-names" {
  value = "${aws_instance.staging-swarm-node.*.public_dns}"
}

output "staging-swarm-nodes-hostnames" {
  value = "${aws_instance.staging-swarm-node.*.private_dns}"
}
