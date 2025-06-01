data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_default_tags" "provider" {}

data "aws_ami" "ubuntu_pro" {
  most_recent = true

  filter {
    name   = "name"
    values = [local.ami_name_pattern_pro]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "state"
    values = [
      "available"
    ]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_subnet" "selected" {
  id = var.consumer_subnet_ids[0]
}

data "aws_vpc" "selected" {
  id = data.aws_subnet.selected.vpc_id
}
