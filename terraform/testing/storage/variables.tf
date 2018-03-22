variable "ami" {
  description = "Ubuntu LTS 16.04 AMD64 HVM EBS"
  default = "ami-f90a4880"
}

variable "machine" {
  default = "t2.micro"
}

variable "storage-gigabytes" {
  default = 2
}
