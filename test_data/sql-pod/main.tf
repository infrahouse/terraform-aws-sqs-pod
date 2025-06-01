module "test" {
  source                       = "./../../"
  service_name                 = "sqs-test"
  consumer_subnet_ids          = var.consumer_subnet_ids
  consumer_asg_min_size        = 1
  consumer_asg_max_size        = 2
  consumer_target_backlog_size = 5
  consumer_userdata            = data.cloudinit_config.config.rendered
}
