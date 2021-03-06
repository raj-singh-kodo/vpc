provider "aws" {
  region = var.region
}


module "vpc" {
  source                  = "../../"
  ipv4_primary_cidr_block = "172.16.0.0/16"
  ipv4_additional_cidr_block_associations = {
    "172.22.0.0/16" = {
      ipv4_cidr_block     = "172.22.0.0/16"
      ipv4_ipam_pool_id   = null
      ipv4_netmask_length = null
    }
  }
  ipv4_cidr_block_association_timeouts = {
    create = "3m"
    delete = "5m"
  }

  assign_generated_ipv6_cidr_block = true

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "0.40.1"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context = module.this.context
}

# Verify that a disabled VPC generates a plan without errors
module "vpc_disabled" {
  source  = "../../"
  enabled = false

  ipv4_primary_cidr_block          = "172.16.0.0/16"
  assign_generated_ipv6_cidr_block = true

  context = module.this.context
}
