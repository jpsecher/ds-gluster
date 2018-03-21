resource "aws_ebs_volume" "staging-storage-01-b" {
  tags {
    Description = "Staging cluster storage"
    Name = "staging-storage-01-b"
    ManagedBy = "terraform"
    Repo = "gitlab:docker-cluster"
    Organisation = "kaleidoscope"
  }
  # TODO: setup a map in variables using data source "available".
  availability_zone = "${var.aws_region}b"
  size = 8
}

resource "aws_instance" "staging-node-01-b" {
  tags {
    Description = "Staging cluster node"
    Name = "staging-node-01-b"
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
  availability_zone = "${var.aws_region}b"
}

resource "aws_volume_attachment" "staging-storage-attachment-01-b" {
  # TODO: Output this constant so it can be used with Ansible.
  device_name = "/dev/xvdb"
  volume_id   = "${aws_ebs_volume.staging-storage-01-b.id}"
  instance_id = "${aws_instance.staging-node-01-b.id}"
}

output "staging-node-01-b-public-name" {
  value = "${aws_instance.staging-node-01-b.public_dns}"
}

output "staging-node-01-b-hostname" {
  # TODO: output hostname instead.
  value = "${aws_instance.staging-node-01-b.private_ip}"
}

output "staging-node-01-b-id" {
  value = "${aws_instance.staging-node-01-b.id}"
}

output "staging-node-01-b-brick-device" {
  value = "${aws_volume_attachment.staging-storage-attachment-01-b.device_name}"
}

output "staging-node-01-b-suite" {
  value = "staging"
}
