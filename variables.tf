variable "consumer_ami_id" {
  description = "AMI id for EC2 instances. By default, latest Ubuntu Pro var.ubuntu_codename."
  type        = string
  default     = null
}

variable "consumer_asg_min_size" {
  description = "Minimal number of EC2 instances in the ASG. By default, the number of subnets."
  type        = number
  default     = null
}

variable "consumer_asg_max_size" {
  description = "Maximum number of EC2 instances in the ASG. By default, the number of subnets plus one."
  type        = number
  default     = null
}


variable "consumer_target_backlog_size" {
  description = "Target number of messages in the SQS backlog per instance in the autoscaling group."
  default     = 100
  type        = number
}

variable "consumer_target_cpu_load" {
  description = "Target CPU load for autoscaling."
  default     = 60
  type        = number
}

variable "consumer_extra_policies" {
  description = "A map of additional policy ARNs to attach to the consumer instance role."
  type        = map(string)
  default     = {}
}

variable "consumer_instance_type" {
  description = "Consumer EC2 Instance type"
  type        = string
  default     = "t3a.micro"
}

variable "consumer_keypair_name" {
  description = "SSH key pair name that will be added to the consumer instance.By default, create and use a new SSH keypair."
  type        = string
  default     = null
}
variable "consumer_on_demand_base_capacity" {
  description = "If specified, the ASG will request spot instances and this will be the minimal number of on-demand instances. Also, warm pool will be disabled."
  type        = number
  default     = null
}

variable "consumer_root_volume_size" {
  description = "Root volume size in consumer EC2 instance in Gigabytes"
  type        = number
  default     = 30
}

variable "consumer_subnet_ids" {
  description = "List of subnet ids where the consumer instances will be created."
  type        = list(string)
}

variable "consumer_ubuntu_codename" {
  description = "Ubuntu version to use for the SQS consumer."
  type        = string
  default     = "noble"
}

variable "consumer_userdata" {
  description = "Userdata text for cloud-init. If not specified, puppet will install the base role."
  type        = string
  default     = null
}

variable "consumer_warm_pool_min_size" {
  description = "How many instances to keep in the warm pool. By default, zero which means the warm pool will give all its instances if ASG needs them."
  type        = number
  default     = 0
}

variable "consumer_warm_pool_max_size" {
  description = "Max allowed number of instances in the warm pool. By default, as many as ASG max size"
  type        = number
  default     = null
}

variable "environment" {
  description = "Environment name string. Used as a puppet environment and in AWS tags."
  type        = string
  default     = "development"
}

variable "fifo_queue" {
  description = "If true, the queue supports FIFO queue behavior."
  type        = bool
  default     = false
}

variable "queue_name" {
  description = "Name of the queue."
  type        = string
  default     = null
}


variable "service_name" {
  description = "A descriptive name for the service that owns the queue."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to resources."
  default     = {}
}

