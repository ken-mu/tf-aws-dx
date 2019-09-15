variable "aws_access_key" {}
variable "aws_access_secret" {}
variable "aws_access_key_tf1" {}
variable "aws_access_secret_tf1" {}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_access_secret
}

provider "aws" {
  alias      = "tf1"
  region     = "us-east-1"
  access_key = var.aws_access_key_tf1
  secret_key = var.aws_access_secret_tf1
}

resource "aws_vpc" "main" {
  cidr_block       = "10.1.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_vpc" "tf1" {
  provider    = "aws.tf1"
  cidr_block  = "10.10.0.0/16"

  tags = {
    Name = "tgw"
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

resource "aws_subnet" "tf1" {
  provider = "aws.tf1"
  vpc_id     = "${aws_vpc.tf1.id}"
  cidr_block = "10.10.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tgw"
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

resource "aws_ec2_transit_gateway_vpc_attachment" "tf1" {
  transit_gateway_id = "${aws_ec2_transit_gateway.example.id}"
  vpc_id             = "${aws_vpc.tf1.id}"

  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"

  subnet_ids = [
    "${aws_subnet.tf1.id}",
  ]
  
  tags = {
    Name = "tf1"
  }
}

resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = "${aws_ec2_transit_gateway.example.id}"
}

resource "aws_ec2_transit_gateway_route_table_association" "main" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.main.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.main.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "main" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.main.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.main.id}"
}

resource "aws_ram_resource_share" "example" {
  name = "example"
  allow_external_principals = true
}

resource "aws_ram_resource_association" "example" {
  resource_arn       = "${aws_ec2_transit_gateway.example.arn}"
  resource_share_arn = "${aws_ram_resource_share.example.arn}"
}

resource "aws_ram_principal_association" "example" {
  principal          = "578044811547"
  resource_share_arn = "${aws_ram_resource_share.example.arn}"
}

resource "aws_ram_resource_share_accepter" "example" {
  provider = "aws.tf1"
  share_arn = "${aws_ram_principal_association.example.resource_share_arn}"
}

