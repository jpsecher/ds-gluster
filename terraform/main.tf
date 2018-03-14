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
    Repo = "gitlab:docker-cluster"
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
    Repo = "gitlab:docker-cluster"
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

resource "aws_ebs_volume" "cluster-storage" {
  count = "${var.cluster_size}"
  tags {
    Name = "cluster-storage-${count.index}"
    Description = "Cluster storage"
    ManagedBy = "terraform"
    Repo = "gitlab:docker-cluster"
    Organisation = "kaleidoscope"
  }
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  size = 8
}

resource "aws_instance" "cluster-node" {
  count = "${var.cluster_size}"
  tags {
    Name = "node-${count.index}"
    Description = "Cluster node"
    ManagedBy = "terraform"
    Repo = "gitlab:docker-cluster"
    Organisation = "kaleidoscope"
  }
  ami = "${var.ami}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "${aws_security_group.cluster-node.id}",
    "${aws_security_group.trusted-ip-access.id}"
  ]
  root_block_device = {
    "delete_on_termination" = true
  }
  key_name = "${var.aws_key_name}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
}

resource "aws_volume_attachment" "cluster-storage-attachement" {
  count = "${var.cluster_size}"
  device_name = "/dev/xvdb"
  volume_id   = "${element(aws_ebs_volume.cluster-storage.*.id,count.index)}"
  instance_id = "${element(aws_instance.cluster-node.*.id,count.index)}"
}
