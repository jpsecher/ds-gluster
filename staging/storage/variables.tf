variable "storage-ami" {
  description = "Ubuntu LTS 16.04 AMD64 HVM EBS"
  default = "ami-f90a4880"
}

variable "storage-machine" {
  default = "t2.micro"
}

variable "storage-cluster-zones" {
  description = "Number of availability zones to spread the storage across"
  default = 2
}

variable "storage-gigabytes" {
  description = "Size in GB of each brick in the storage cluster"
  default = 2
}

// Should be brick-0-device
variable "brick-device" {
  default = "/dev/xvdb"
}

variable "brick-1-device" {
  default = "/dev/xvdc"
}
