output "vpc_id" {
  value = aws_vpc.impact_genome_vpc.id
}
output "private_subnets" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private_subnet[*].id  # Correct reference to the private subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public_subnet[*].id  # Correct reference to the public subnets
}

