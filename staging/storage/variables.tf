variable "storage-ami" {
  description = "Ubuntu LTS 16.04 AMD64 HVM EBS"
  default = "ami-f90a4880"
}

variable "storage-machine" {
  default = "t2.micro"
}

variable "storage-cluster-zones" {
  description = "Number of availability zones to spread the storage across"
  default = 3
}

variable "storage-gigabytes" {
  description = "Size in GB of each brick in the storage cluster"
  default = 2
}

variable "brick-device" {
  default = "/dev/xvdb"
}
