variable "aws_access_key" {}
variable "aws_access_secret" {}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_access_secret
}

data "aws_ec2_transit_gateway" "example" {
  id = "example"
}

resource "aws_ec2_transit_gateway_route_table" "ctrl" {
  transit_gateway_id = "${aws_ec2_transit_gateway.example.id}"
}
