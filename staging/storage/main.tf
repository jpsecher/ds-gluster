provider "aws" {
  region = "${var.aws_region}"
  version = "~> 1.10"
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "staging-storage" {
  name = "${var.environment} storage"
  # TODO: limit to TCP and UDP ports 24007-24008 and 49152-49153 (2 bricks) for
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
  tags {
    Description = "Default security group for storage nodes in ${var.environment}"
    Name = "${var.environment}-storage"
    ManagedBy = "terraform"
    Repo = "${var.repository}"
    Organisation = "${var.organisation}"
    Environment = "${var.environment}"
  }
}

resource "aws_ebs_volume" "staging-storage" {
  count = "${var.storage-cluster-zones}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  size = "${var.storage-gigabytes}"
  tags {
    Description = "${var.environment} storage"
    Name = "${var.environment}-storage-${count.index}"
    ManagedBy = "terraform"
    Repo = "${var.repository}"
    Organisation = "${var.organisation}"
    Environment = "${var.environment}"
  }
}

resource "aws_instance" "staging-storage-node" {
  count = "${var.storage-cluster-zones}"
  ami = "${var.storage-ami}"
  instance_type = "${var.storage-machine}"
  vpc_security_group_ids = ["${aws_security_group.staging-storage.id}"]
  root_block_device = {
    "delete_on_termination" = true
  }
  key_name = "${var.aws_key_name}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  tags {
    Description = "${var.environment} gluster node"
    Name = "${var.environment}-storage-node-${count.index}"
    ManagedBy = "terraform"
    Repo = "${var.repository}"
    Organisation = "${var.organisation}"
    Environment = "${var.environment}"
  }
}

resource "aws_volume_attachment" "staging-storage-attachment" {
  count = "${var.storage-cluster-zones}"
  device_name = "${var.brick-device}"
  volume_id   = "${aws_ebs_volume.staging-storage.*.id[count.index]}"
  instance_id = "${aws_instance.staging-storage-node.*.id[count.index]}"
  # Fix for https://github.com/terraform-providers/terraform-provider-aws/issues/2084.
  provisioner "remote-exec" {
    when = "destroy"
    inline = ["sudo poweroff"]
    #on_failure = "continue"
    connection {
      type = "ssh"
      host = "${aws_instance.staging-storage-node.*.public_dns[count.index]}"
      user = "ubuntu"
      private_key = "${file("~/.ssh/${var.aws_key_name}.pem")}"
      agent = false
    }
  }
  # Allow instance some time to power down before attempting volume detachment.
  provisioner "local-exec" {
    when = "destroy"
    command = "sleep 30"
  }
}

output "staging-gluster-storage-public-name" {
  value = "${aws_instance.staging-storage-node.*.public_dns[0]}"
}

output "staging-storage-nodes-public-name" {
  value = "${aws_instance.staging-storage-node.*.public_dns}"
}

output "staging-storage-nodes-hostnames" {
  value = "${aws_instance.staging-storage-node.*.private_dns}"
}

output "staging-brick-device" {
  value = "${var.brick-device}"
}
