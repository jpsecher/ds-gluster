variable "swarm-ami" {
  description = "Ubuntu LTS 16.04 AMD64 HVM EBS"
  default = "ami-f90a4880"
}

variable "swarm-machine" {
  default = "t2.micro"
}

variable "swarm-cluster-zones" {
  description = "Number of availability zones to spread the swarm across"
  default = 2
}
