output "id" {
  value       = aws_ecs_cluster.this.id
  sensitive   = false
  description = "ECS Cluster ID"
}

output "name" {
  value       = aws_ecs_cluster.this.name
  sensitive   = false
  description = "ECS Cluster Name"
}

output "capacity_provider_name" {
  value       = aws_ecs_capacity_provider.this.name
  sensitive   = false
  description = "ECS Capacity Provider Name"
}

output "auto_scaling_group_name" {
  value       = aws_autoscaling_group.ecs.name
  sensitive   = false
  description = "Auto Scaling Group Name"
}

output "node_launch_template_id" {
  value       = aws_launch_template.ecs_node.id
  sensitive   = false
  description = "Node Launch Template ID"
}

output "node_launch_template_latest_version" {
  value       = aws_launch_template.ecs_node.latest_version
  sensitive   = false
  description = "Node Launch Template Latest Version"
}

output "node_launch_template_image_id" {
  value       = aws_launch_template.ecs_node.image_id
  sensitive   = true
  description = "Node Launch Template Image ID"
}

output "node_iam_role" {
  value       = aws_iam_role.ecs_node.name
  sensitive   = false
  description = "Node IAM Role Name"
}

output "node_iam_profile" {
  value       = aws_iam_instance_profile.ecs_node.name
  sensitive   = false
  description = "Node IAM Instance Profile Name"
}
