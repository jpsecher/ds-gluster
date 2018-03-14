variable "aws_region" {
  default = "eu-west-1"
}

variable "cluster_size" {
  description = "How many availability zones to use for the cluster."
  default = 2
}

variable "aws_key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default = "ec2-lundogbendsen-jp"
  # Must be one of
  # https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs:sort=keyName
}

variable "safe_ips" {
  description = "Trusted IPs as comma-separated strings of CIDR blocks."
  default = "5.186.121.226/32"
}

variable "pem_file" {
  description = "Local SSH key that matches AWS key."
  default = "~/.ssh/ec2-monolit-tier-1.pem"
}

variable "ami" {
  description = "Ubuntu LTS 16.04 AMD64 HVM EBS"
  default = "ami-f90a4880"
}

/*
variable "instance_type" {
  description = "Instance type"
  default = "t2.micro"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "/home/core/.ssh/id_rsa.pub"
}

variable "bootstrap_path" {
  description = "Script to install Docker Engine"
  default = "install-docker.sh"
}
*/
