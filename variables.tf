## Variables used by all environments.

variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default = "ec2-lundogbendsen-jp"
  # Must be one of
  # https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs:sort=keyName
}

variable "pem_file" {
  description = "Local SSH key that matches AWS key."
  default = "~/.ssh/ec2-monolit-tier-1.pem"
}

variable "organisation" {
  description = "Used for tagging resources"
  default = "kaleidoscope"
}

variable "repository" {
  description = "Used for tagging resources"
  default = "github.com/jpsecher/ds-gluster"
}
