# terraform-aws-sqs-pod

This Terraform module is designed to provision an Amazon Simple Queue Service (SQS) queue along with
an auto-scaling group that manages consumer EC2 instances. The SQS queue serves as a reliable messaging service,
allowing decoupled components of an application to communicate asynchronously.

<div style="text-align: center;">
    <img src="assests%2Fsqs-asg.png" alt="SQS queue and ASG" width="600"/>
</div>

The auto-scaling group ensures that the number of EC2 instances can dynamically adjust based on the workload, 
providing scalability and high availability for processing messages from the SQS queue. 

The auto-scaling capabilities of this module are implemented through two distinct policies 
within the auto-scaling group (ASG). 

The first policy monitors the average CPU usage of the EC2 instances, 
maintaining it at a target level of 60% by default. 
This ensures that the instances are neither underutilized nor overburdened, 
optimizing resource usage and performance. 

The second policy focuses on the SQS queue's message count, aiming to keep the number of messages per instance 
below a threshold of 100. 
If the message count exceeds this limit, the policy triggers the addition of more EC2 instances 
to handle the increased load effectively. 
Together, these policies enable dynamic scaling based on both CPU utilization and message processing demands, 
ensuring that the application remains responsive and efficient under varying workloads.

<div style="text-align: center;">
    <img src="assests%2Fqueue_size-policy.png" alt="Queue backlog size policy" width="600"/>
</div>

Additionally, this module provides flexibility in how the auto-scaling group is configured. 
It can be set up to utilize spot instances, which can significantly reduce costs while maintaining scalability. 
Alternatively, the ASG can be configured with a warm pool, allowing for quicker instance availability 
by keeping a certain number of pre-initialized instances ready to handle incoming workloads. 
This ensures that the application can respond promptly to changes in demand 
while optimizing resource utilization and cost efficiency.

## Usage

To utilize this module in your Terraform repository, you can call it as follows:


```hcl
module "test" {
  source  = "infrahouse/sqs-pod/aws"
  version = "0.2.0"
  
  service_name                 = "sqs-test"                               # A descriptive name for the service that owns the SQS queue.
  consumer_subnet_ids          = var.consumer_subnet_ids                  # List of subnet IDs where the consumer EC2 instances will be created.
  consumer_asg_min_size        = 1                                        # Minimum number of consumer EC2 instances in the ASG.                  
  consumer_asg_max_size        = 10                                       # Maximum number of consumer EC2 instances in the ASG.              
  consumer_userdata            = data.cloudinit_config.config.rendered    # Userdata script for cloud-init to configure the EC2 instances.
}
```

### Consumer Instance Provisioning

Upon startup, the EC2 instance runs the cloud-init script.
Below is an example of a cloud-init script:

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.31 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.31 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_instance-profile"></a> [instance-profile](#module\_instance-profile) | registry.infrahouse.com/infrahouse/instance-profile/aws | 1.8.1 |
| <a name="module_userdata"></a> [userdata](#module\_userdata) | registry.infrahouse.com/infrahouse/cloud-init/aws | 1.18.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.consumer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.cpu_load](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.queue_size](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_launch_template.consumer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.consumer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sqs_queue.queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_vpc_security_group_egress_rule.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.icmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_string.asg_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.profile-suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.key_pair](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.ubuntu_pro](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.required_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_consumer_ami_id"></a> [consumer\_ami\_id](#input\_consumer\_ami\_id) | AMI id for EC2 instances. By default, latest Ubuntu Pro var.ubuntu\_codename. | `string` | `null` | no |
| <a name="input_consumer_asg_max_size"></a> [consumer\_asg\_max\_size](#input\_consumer\_asg\_max\_size) | Maximum number of EC2 instances in the ASG. By default, the number of subnets plus one. | `number` | `null` | no |
| <a name="input_consumer_asg_min_size"></a> [consumer\_asg\_min\_size](#input\_consumer\_asg\_min\_size) | Minimal number of EC2 instances in the ASG. By default, the number of subnets. | `number` | `null` | no |
| <a name="input_consumer_extra_policies"></a> [consumer\_extra\_policies](#input\_consumer\_extra\_policies) | A map of additional policy ARNs to attach to the consumer instance role. | `map(string)` | `{}` | no |
| <a name="input_consumer_instance_type"></a> [consumer\_instance\_type](#input\_consumer\_instance\_type) | Consumer EC2 Instance type | `string` | `"t3a.micro"` | no |
| <a name="input_consumer_keypair_name"></a> [consumer\_keypair\_name](#input\_consumer\_keypair\_name) | SSH key pair name that will be added to the consumer instance.By default, create and use a new SSH keypair. | `string` | `null` | no |
| <a name="input_consumer_on_demand_base_capacity"></a> [consumer\_on\_demand\_base\_capacity](#input\_consumer\_on\_demand\_base\_capacity) | If specified, the ASG will request spot instances and this will be the minimal number of on-demand instances. Also, warm pool will be disabled. | `number` | `null` | no |
| <a name="input_consumer_root_volume_size"></a> [consumer\_root\_volume\_size](#input\_consumer\_root\_volume\_size) | Root volume size in consumer EC2 instance in Gigabytes | `number` | `30` | no |
| <a name="input_consumer_subnet_ids"></a> [consumer\_subnet\_ids](#input\_consumer\_subnet\_ids) | List of subnet ids where the consumer instances will be created. | `list(string)` | n/a | yes |
| <a name="input_consumer_target_backlog_size"></a> [consumer\_target\_backlog\_size](#input\_consumer\_target\_backlog\_size) | Target number of messages in the SQS backlog per instance in the autoscaling group. | `number` | `100` | no |
| <a name="input_consumer_target_cpu_load"></a> [consumer\_target\_cpu\_load](#input\_consumer\_target\_cpu\_load) | Target CPU load for autoscaling. | `number` | `60` | no |
| <a name="input_consumer_ubuntu_codename"></a> [consumer\_ubuntu\_codename](#input\_consumer\_ubuntu\_codename) | Ubuntu version to use for the SQS consumer. | `string` | `"noble"` | no |
| <a name="input_consumer_userdata"></a> [consumer\_userdata](#input\_consumer\_userdata) | Userdata text for cloud-init. If not specified, puppet will install the base role. | `string` | `null` | no |
| <a name="input_consumer_warm_pool_max_size"></a> [consumer\_warm\_pool\_max\_size](#input\_consumer\_warm\_pool\_max\_size) | Max allowed number of instances in the warm pool. By default, as many as ASG max size | `number` | `null` | no |
| <a name="input_consumer_warm_pool_min_size"></a> [consumer\_warm\_pool\_min\_size](#input\_consumer\_warm\_pool\_min\_size) | How many instances to keep in the warm pool. By default, zero which means the warm pool will give all its instances if ASG needs them. | `number` | `0` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name string. Used as a puppet environment and in AWS tags. | `string` | `"development"` | no |
| <a name="input_fifo_queue"></a> [fifo\_queue](#input\_fifo\_queue) | If true, the queue supports FIFO queue behavior. | `bool` | `false` | no |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name) | Name of the queue. | `string` | `null` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | A descriptive name for the service that owns the queue. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to resources. | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_queue_name"></a> [queue\_name](#output\_queue\_name) | Name of the SQS queue |
| <a name="output_queue_url"></a> [queue\_url](#output\_queue\_url) | URL of the SQS queue |
