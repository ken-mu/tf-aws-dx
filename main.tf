variable "aws_access_key" {}
variable "aws_access_secret" {}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_access_secret
}

resource "aws_vpc" "main" {
  cidr_block       = "10.1.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "private-1" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.1.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-1"
  }
}

resource "aws_ec2_transit_gateway" "example" {
  amazon_side_asn = "64512"
  auto_accept_shared_attachments = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  description = "example"
  dns_support = "enable"
  tags = {
    Name = "example"  
  }
  vpn_ecmp_support = "disable"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  transit_gateway_id = "${aws_ec2_transit_gateway.example.id}"
  vpc_id             = "${aws_vpc.main.id}"

  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"

  subnet_ids = [
    "${aws_subnet.private-1.id}",
  ]
  
  tags = {
    Name = "main"
  }
}
