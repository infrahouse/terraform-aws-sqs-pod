resource "aws_autoscaling_policy" "cpu_load" {
  autoscaling_group_name = aws_autoscaling_group.consumer.name
  name                   = "cpu_load_target"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.consumer_target_cpu_load
  }
}

resource "aws_autoscaling_policy" "queue_size" {
  autoscaling_group_name = aws_autoscaling_group.consumer.name
  name                   = "queue_size"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    target_value = var.consumer_target_backlog_size
    customized_metric_specification {
      metrics {
        label = "Get the queue size (the number of messages waiting to be processed)"
        id    = "m1"
        metric_stat {
          metric {
            namespace   = "AWS/SQS"
            metric_name = "ApproximateNumberOfMessagesVisible"
            dimensions {
              name  = "QueueName"
              value = aws_sqs_queue.queue.name
            }
          }
          stat   = "Sum"
          period = 60
        }
        return_data = false
      }
      metrics {
        label = "Get the group size (the number of InService instances)"
        id    = "m2"
        metric_stat {
          metric {
            namespace   = "AWS/AutoScaling"
            metric_name = "GroupInServiceInstances"
            dimensions {
              name  = "AutoScalingGroupName"
              value = aws_autoscaling_group.consumer.name
            }
          }
          stat   = "Average"
          period = 60
        }
        return_data = false
      }
      metrics {
        label       = "Calculate the backlog per instance"
        id          = "e1"
        expression  = "m1 / m2"
        return_data = true
      }
    }
  }
}
