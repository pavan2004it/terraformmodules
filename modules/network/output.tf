output "priv_subnet_ids" {
  value = "${aws_subnet.priv.*.id}"
}

output "pub_subnet_ids" {
  value = "${aws_subnet.pub.*.id}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}