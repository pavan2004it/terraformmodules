variable "vpc_cidr" {}
variable "az_count" {}
variable "azs" { type = "list" }
variable "tags" { type = "map" }

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy 	= "default"
  enable_dns_hostnames = "true"

  tags = "${merge(var.tags, map("Name", "${var.tags["Environment"]}"))}"
}

//Elastic IP/EIP
resource "aws_eip" "ngw" {
  vpc = true
  count = "${var.az_count}"
}

// Gateways
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(var.tags, map("Name", "${var.tags["Environment"]}-igw"))}"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = "${element(aws_eip.ngw.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.pub.*.id, count.index)}"
  depends_on = ["aws_internet_gateway.igw"]
  count = "${var.az_count}"
}

resource "aws_route_table" "pub" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = "${merge(var.tags, map("Name", "${var.tags["Environment"]}-pub"))}"
}

/**
 * Pub
 */
resource "aws_subnet" "pub" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, 4, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = true
  count = "${var.az_count}"

  tags = "${merge(var.tags, map("Name", "${var.tags["Environment"]}-sn-pub-${format("%02d", count.index)}"))}"
}

resource "aws_route_table_association" "pub" {
  subnet_id = "${element(aws_subnet.pub.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.pub.*.id, count.index)}"
  count = "${var.az_count}"
}

resource "aws_security_group" "pub" {
  name = "pub-sg"
  description = "Houses VPN instances and allows SSH and VPN traffic from internet."
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = "${merge(var.tags, map("Name", "${var.tags["Environment"]}-sg-dmz"))}"
}

/**
 * Priv
 */

resource "aws_route_table" "priv" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.ngw.*.id, count.index)}"
  }

  count = "${var.az_count}"

  tags = "${merge(var.tags, map("Name", "${var.tags["Environment"]}-priv-${format("%02d", count.index)}"))}"
}

resource "aws_subnet" "priv" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, 4, var.az_count+count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false

  count = "${var.az_count}"

  tags = "${merge(var.tags, map("Name", "${var.tags["Environment"]}-sn-priv"))}"
}

resource "aws_route_table_association" "priv" {
  subnet_id = "${element(aws_subnet.priv.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.priv.*.id, count.index)}"
  count = "${var.az_count}"
}
