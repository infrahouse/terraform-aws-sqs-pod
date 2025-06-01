locals {
  module_version = "0.1.0"

  default_module_tags = merge(
    var.tags,
    {
      service : var.service_name
      created_by_module : "infrahouse/sqs-pod/aws"
    }
  )

  ami_id               = var.consumer_ami_id == null ? data.aws_ami.ubuntu_pro.id : var.consumer_ami_id
  ami_name_pattern_pro = "ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-${var.consumer_ubuntu_codename}-*"
}
