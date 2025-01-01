output "subnet_ids" {
  description = "Private Subnet Ids"
  value       = module.vpc.private_subnets
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
