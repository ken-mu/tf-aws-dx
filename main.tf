variable "aws_access_key" {}
variable "aws_access_secret" {}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_access_secret
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
