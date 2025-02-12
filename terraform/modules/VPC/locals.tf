################################################################################
# VPC
################################################################################

locals {
  create_vpc = var.create_vpc

  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = try(aws_vpc_ipv4_cidr_block_association.this[0].vpc_id, aws_vpc.this[0].id, "")

  create_public_subnets = local.create_vpc && local.len_public_subnets > 0
  create_private_subnets = local.create_vpc && local.len_private_subnets > 0
  create_private_network_acl = local.create_private_subnets && var.private_dedicated_network_acl
  create_database_network_acl = local.create_database_subnets && var.database_dedicated_network_acl


  len_public_subnets      = max(length(var.public_subnets), length(var.public_subnet_ipv6_prefixes))
  len_private_subnets     = max(length(var.private_subnets), length(var.private_subnet_ipv6_prefixes))
  len_database_subnets    = max(length(var.database_subnets), length(var.database_subnet_ipv6_prefixes))


  max_subnet_length = max(
    local.len_private_subnets,
    local.len_public_subnets,
    local.len_database_subnets,
  )

}

