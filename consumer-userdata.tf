module "userdata" {
  source          = "registry.infrahouse.com/infrahouse/cloud-init/aws"
  version         = "1.18.0"
  environment     = var.environment
  role            = "base"
  ubuntu_codename = var.consumer_ubuntu_codename
  packages = concat(
    [
      "python-is-python3",
    ]
  )
}
