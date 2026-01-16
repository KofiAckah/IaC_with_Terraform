# Local values
locals {
  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project_name
      Environment = var.environment
    }
  )
}

# Network Module
module "network" {
  source = "./modules/Network"
  
  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  common_tags  = local.common_tags
}


# # Security Module
# module "security" {
#   source = "./modules/Security"
  
#   vpc_id       = module.network.vpc_id
#   project_name = var.project_name
#   tags         = local.common_tags
# }

# # Compute Module
# module "compute" {
#   source = "./modules/Compute"
  
#   subnet_id          = module.network.public_subnet_id
#   security_group_ids = [module.security.web_sg_id]
#   project_name       = var.project_name
#   tags               = local.common_tags
# }