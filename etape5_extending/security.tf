resource "aws_security_group" "servers" {
  vpc_id      = "${aws_vpc.nomad.id}"
  name        = "servers_sg"

  # SSH
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Consul RPC + Serf
  ingress {
    protocol  = "tcp"
    from_port = 8300
    to_port   = 8302
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Consul RPC + Serf (UDP)
  ingress {
    protocol  = "udp"
    from_port = 8301
    to_port   = 8302
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Consul HTTP API
  ingress {
    protocol  = "tcp"
    from_port = 8500
    to_port   = 8500
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nomad RPC + Serf
  ingress {
    protocol  = "tcp"
    from_port = 4646
    to_port   = 4648
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nomad Serf (UDP)
  ingress {
    protocol  = "udp"
    from_port = 4648
    to_port   = 4648
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_security_group" "clients" {
  vpc_id      = "${aws_vpc.nomad.id}"
  name        = "clients_sg"

  # SSH
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Consul RPC + Serf
  ingress {
    protocol  = "tcp"
    from_port = 8300
    to_port   = 8301
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Consul RPC + Serf (UDP)
  ingress {
    protocol  = "udp"
    from_port = 8301
    to_port   = 8301
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Consul HTTP API
  ingress {
    protocol  = "tcp"
    from_port = 8500
    to_port   = 8500
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nomad RPC + Serf
  ingress {
    protocol  = "tcp"
    from_port = 4646
    to_port   = 4647
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nomad Apps TCP
  ingress {
    protocol  = "tcp"
    from_port = 20000
    to_port   = 60000
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nomad Apps UDP
  ingress {
    protocol  = "udp"
    from_port = 20000
    to_port   = 60000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = ["aws_internet_gateway.gw"]
}
