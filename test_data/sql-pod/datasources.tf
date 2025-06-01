data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  boostrap_script_path = "/usr/local/bin/consumer-bootstrap.sh"
}
data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = join(
      "\n",
      [
        "#cloud-config",
        yamlencode(
          merge(
            {
              write_files : concat(
                [
                  {
                    content : "export AWS_DEFAULT_REGION=${data.aws_region.current.name}",
                    path : "/etc/profile.d/aws.sh",
                    permissions : "0644"
                  },
                  {
                    content : join(
                      "\n",
                      [
                        "[default]",
                        "region=${data.aws_region.current.name}"
                      ]
                    ),
                    path : "/root/.aws/config",
                    permissions : "0600"
                  },
                  {
                    content : file("${path.module}/files/consumer-bootstrap.sh"),
                    path : local.boostrap_script_path,
                    permissions : "0755"
                  },
                  {
                    content : templatefile(
                      "${path.module}/files/consumer.json",
                      {
                        queue_url = module.test.queue_url
                      }
                    ),
                    path : "/etc/consumer.json",
                    permissions : "0644"
                  },
                ],
              )
              package_update : true,
              apt : {
                sources : merge(
                  {
                    infrahouse : {
                      source : "deb [signed-by=$KEY_FILE] https://release-${var.ubuntu_codename}.infrahouse.com/ $RELEASE main"
                      key : file("${path.module}/files/DEB-GPG-KEY-infrahouse-${var.ubuntu_codename}")
                    }
                  },
                )
              }
              packages : concat(
                [
                  "make",
                  "gcc",
                  "infrahouse-toolkit"
                ],
              ),
              runcmd : concat(
                [
                  local.boostrap_script_path,
                ],
              )
            }
          )
        )
      ]
    )
  }
}
