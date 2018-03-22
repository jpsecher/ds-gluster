provider "aws" {
  region = "${var.aws_region}"
  version = "~> 1.10"
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "testing-swarm" {
  name = "testing swarm"
  tags {
    Description = "Default security group for swarm nodes in suite testing"
    Name = "testing-storage"
    ManagedBy = "terraform"
    Repo = "${var.repository}"
    Organisation = "${var.organisation}"
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
  }
  ami = "${var.ami}"
  # TODO: setup a map in variables.
  instance_type = "t2.micro"
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
    inline = ["sudo poweroff"]
    when = "destroy"
    on_failure = "continue"
    connection {
      type = "ssh"
      host = "${aws_instance.testing-storage-node.private_dns}"
      user = "ubuntu"
      private_key = "${var.aws_key_name}"
      agent = false
    }
  }
  # Allow instance some time to power down before attempting volume detachment.
  provisioner "local-exec" {
    command = "sleep 10"
    when = "destroy"
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

----


resource "aws_ebs_volume" "staging-storage-01-a" {
  tags {
    Description = "Staging cluster storage"
    Name = "staging-storage-01-a"
    ManagedBy = "terraform"
    Repo = "gitlab:docker-cluster"
    Organisation = "kaleidoscope"
  }
  # TODO: setup a map in variables using data source "available".
  availability_zone = "${var.aws_region}a"
  size = 8
}

resource "aws_instance" "staging-node-01-a" {
  tags {
    Description = "Staging cluster node"
    Name = "staging-node-01-a"
    ManagedBy = "terraform"
    Repo = "gitlab:docker-cluster"
    Organisation = "kaleidoscope"
  }
  ami = "${var.ami}"
  # TODO: setup a map in variables.
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "${aws_security_group.cluster-node.id}",
    "${aws_security_group.trusted-ip-access.id}"
  ]
  root_block_device = {
    "delete_on_termination" = true
  }
  key_name = "${var.aws_key_name}"
  # TODO: setup a map in variables using data source "available".
  availability_zone = "${var.aws_region}a"
}

resource "aws_volume_attachment" "staging-storage-attachment-01-a" {
  # TODO: Output this constant so it can be used with Ansible.
  device_name = "/dev/xvdb"
  volume_id   = "${aws_ebs_volume.staging-storage-01-a.id}"
  instance_id = "${aws_instance.staging-node-01-a.id}"
}

output "staging-node-01-a-public-name" {
  value = "${aws_instance.staging-node-01-a.public_dns}"
}

output "staging-node-01-a-hostname" {
  # TODO: output hostname instead.
  value = "${aws_instance.staging-node-01-a.private_ip}"
}

output "staging-node-01-a-id" {
  value = "${aws_instance.staging-node-01-a.id}"
}

output "staging-node-01-a-brick-device" {
  value = "${aws_volume_attachment.staging-storage-attachment-01-a.device_name}"
}

output "staging-node-01-a-suite" {
  value = "staging"
}
