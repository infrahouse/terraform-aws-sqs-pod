output "queue_name" {
  description = "Name of the SQS queue"
  value       = aws_sqs_queue.queue.name
}

output "queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.queue.url
}
