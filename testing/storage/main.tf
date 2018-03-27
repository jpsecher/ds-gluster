provider "aws" {
  region = "${var.aws_region}"
  version = "~> 1.10"
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "testing-storage" {
  tags {
    Description = "Default security group for storage nodes in suite testing"
    Name = "testing-storage"
    ManagedBy = "terraform"
    Repo = "${var.repository}"
    Organisation = "${var.organisation}"
    Environment = "${var.environment}"
  }
  # TODO: limit to TCP and UDP ports 24007-24008 and 49152-49152 (1 brick) for
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

resource "aws_ebs_volume" "testing-storage" {
  tags {
    Description = "testing storage"
    Name = "testing-storage"
    ManagedBy = "terraform"
    Repo = "${var.repository}"
    Organisation = "${var.organisation}"
    Environment = "${var.environment}"
  }
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  size = "${var.storage-gigabytes}"
}

resource "aws_instance" "testing-storage-node" {
  tags {
    Description = "testing gluster node"
    Name = "testing-storage-node"
    ManagedBy = "terraform"
    Repo = "${var.repository}"
    Organisation = "${var.organisation}"
    Environment = "${var.environment}"
  }
  ami = "${var.ami}"
  instance_type = "${var.machine}"
  vpc_security_group_ids = ["${aws_security_group.testing-storage.id}"]
  root_block_device = {
    "delete_on_termination" = true
  }
  key_name = "${var.aws_key_name}"
  # TODO: setup a map in variables using data source "available".
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_volume_attachment" "testing-storage-attachment" {
  device_name = "/dev/xvdb"
  volume_id   = "${aws_ebs_volume.testing-storage.id}"
  instance_id = "${aws_instance.testing-storage-node.id}"
  # Fix for https://github.com/terraform-providers/terraform-provider-aws/issues/2084.
  provisioner "remote-exec" {
    when = "destroy"
    inline = ["sudo poweroff"]
    #on_failure = "continue"
    connection {
      type = "ssh"
      host = "${aws_instance.testing-storage-node.public_dns}"
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

output "testing-storage-node-public-name" {
  value = "${aws_instance.testing-storage-node.public_dns}"
}

output "testing-storage-node-hostname" {
  value = "${aws_instance.testing-storage-node.private_dns}"
}

output "testing-storage-node-brick-device" {
  value = "${aws_volume_attachment.testing-storage-attachment.device_name}"
}
