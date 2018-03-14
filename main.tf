provider "aws" {
  region = "${var.aws_region}"
  version = "~> 1.10"
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "trusted-ip-access" {
  name = "trusted access"
  tags {
    Name = "trusted-ip-access"
    Description = "Access SSH and Docker from safe IPs"
    ManagedBy = "terraform"
    Repo = "swarm-1"
    Organisation = "kaleidoscope"
  }
  # SSH access from safe IPs.
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.safe_ips)}"]
  }
  # Docker Daemon Remote access from safe IPs.
  ingress {
    from_port = 2376
    to_port = 2376
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.safe_ips)}"]
  }
  # Outbound internet access.
}

resource "aws_security_group" "cluster-node" {
  name = "cluster node default"
  tags {
    Name = "cluster-node"
    Description = "Default security group for cluster nodes"
    ManagedBy = "terraform"
    Repo = "swarm-1"
    Organisation = "kaleidoscope"
  }
  ingress {
    from_port = 0,
    to_port = 0,
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # TODO: limit to internal network.
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "cluster-node" {
  count = "${var.cluster_size}"
  tags {
    Name = "node-${count.index}"
    Description = "Cluster node"
    ManagedBy = "terraform"
    Repo = "swarm-1"
    Organisation = "kaleidoscope"
  }
  ami = "${var.ami}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "${aws_security_group.cluster-node.id}",
    "${aws_security_group.trusted-ip-access.id}"
  ]
  root_block_device = {
    "volume_size" = 8
    "delete_on_termination" = true
  }
  key_name = "${var.aws_key_name}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
}
