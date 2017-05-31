resource "aws_vpc" "nomad" {
  cidr_block = "10.59.0.0/16"
}

resource "aws_subnet" "pub" {
  cidr_block        = "${cidrsubnet(aws_vpc.nomad.cidr_block, 8, 1)}"
  availability_zone = "${var.region}a"
  vpc_id            = "${aws_vpc.nomad.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.nomad.id}"
}

resource "aws_route_table" "pub" {
  vpc_id = "${aws_vpc.nomad.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "pub" {
  subnet_id      = "${aws_subnet.pub.id}"
  route_table_id = "${aws_route_table.pub.id}"
}
