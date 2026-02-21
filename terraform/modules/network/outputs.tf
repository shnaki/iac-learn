output "subnet_ids" {
  value = [aws_subnet.public.id]
}

output "security_group_ids" {
  value = [aws_security_group.ecs_tasks.id]
}
