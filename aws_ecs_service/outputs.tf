output "id" {
  value       = aws_ecs_service.this.id
  sensitive   = false
  description = "ECS Service ID"
}

output "name" {
  value       = aws_ecs_service.this.name
  sensitive   = false
  description = "ECS Service Name"
}

output "task_iam_role" {
  value       = aws_iam_role.ecs_task_role.name
  sensitive   = false
  description = "ECS Task IAM Role"
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  sensitive   = false
  description = "ECS Task Definition ARN"
}

output "cloudwatch_log_group_arn" {
  value       = aws_cloudwatch_log_group.ecs_task.arn
  sensitive   = false
  description = "CloudWatch Log Group ARN"
}
