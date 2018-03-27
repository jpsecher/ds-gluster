variable "swarm-cluster-zones" {
  description = "Number of availability zones to spread the swarm across"
  default = 1
}

variable "swarm-node-image" {
  description = "Individual machine images so that it is possible to make a rolling upgrade"
  default = {
    # Ubuntu LTS 16.04 AMD64 HVM EBS
    "0" = "ami-f90a4880"
    "1" = "ami-f90a4880"
    "2" = "ami-f90a4880"
  }
}

variable "swarm-node-type" {
  description = "Individual EC2 sizes so that it is possible to make a rolling upgrade"
  default = {
    "0" = "t2.micro"
    "1" = "t2.micro"
    "2" = "t2.micro"
  }
}
