output "availability-zones" {
  value = "${data.aws_availability_zones.available.names}"
}

output "cluster-nodes" {
  value = "${aws_instance.cluster-node.*.public_dns}"
}
