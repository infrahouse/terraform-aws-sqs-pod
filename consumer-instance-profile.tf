data "aws_iam_policy" "ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "required_permissions" {
  statement {
    actions = [
      "sts:GetCallerIdentity",
      "ec2:DescribeInstances",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "sqs:deletemessage",
      "sqs:receivemessage",
    ]
    resources = [
      aws_sqs_queue.queue.arn
    ]
  }
}

resource "random_string" "profile-suffix" {
  length  = 12
  special = false
}

module "instance-profile" {
  source       = "registry.infrahouse.com/infrahouse/instance-profile/aws"
  version      = "1.8.1"
  permissions  = data.aws_iam_policy_document.required_permissions.json
  profile_name = "sqs-pod-${random_string.profile-suffix.result}"
  extra_policies = merge(
    {
      ssm : data.aws_iam_policy.ssm.arn
    },
    var.consumer_extra_policies
  )
}
