module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  cluster_name         = var.cluster_name
}

module "security_groups" {
  source       = "./modules/security_groups"
  vpc_id       = module.vpc.vpc_id
  cluster_name = var.cluster_name
}

module "iam" {
  source                  = "./modules/iam"
  cluster_name            = var.cluster_name
  student_id              = var.student_id
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  account_id              = "425221105441"
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  cluster_role_arn   = module.iam.eks_cluster_role_arn
  node_role_arn      = module.iam.eks_node_role_arn
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  eks_nodes_sg_id    = module.security_groups.eks_nodes_sg_id
  node_instance_type = var.node_instance_type
  node_desired_size  = var.node_desired_size
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size
}

module "rds" {
  source             = "./modules/rds"
  cluster_name       = var.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_mysql_sg_id    = module.security_groups.rds_mysql_sg_id
  rds_postgres_sg_id = module.security_groups.rds_postgres_sg_id
  db_username        = var.db_username
  db_password        = var.db_password
}

module "dynamodb" {
  source       = "./modules/dynamodb"
  cluster_name = var.cluster_name
}

module "s3_lambda" {
  source     = "./modules/s3_lambda"
  student_id = var.student_id
}
