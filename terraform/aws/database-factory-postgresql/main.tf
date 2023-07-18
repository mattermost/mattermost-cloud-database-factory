terraform {
  required_version = ">= 0.14.5"
  backend "s3" {
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.1"
    }
  }
}


provider "aws" {
  region = var.region
  alias  = "deployment"
}


module "rds_setup" {
  source                           = "../modules/rds-aurora-postgresql"
  vpc_id                           = var.vpc_id
  db_id                            = var.db_id
  environment                      = var.environment
  port                             = var.port
  engine                           = var.engine
  engine_version                   = var.engine_version
  username                         = var.username
  password                         = var.password
  final_snapshot_identifier_prefix = var.final_snapshot_identifier_prefix
  skip_final_snapshot              = var.skip_final_snapshot
  deletion_protection              = var.deletion_protection
  backup_retention_period          = var.backup_retention_period
  preferred_backup_window          = var.preferred_backup_window
  preferred_maintenance_window     = var.preferred_maintenance_window
  storage_encrypted                = var.storage_encrypted
  apply_immediately                = var.apply_immediately
  copy_tags_to_snapshot            = var.copy_tags_to_snapshot
  instance_type                    = var.instance_type
  monitoring_interval              = var.monitoring_interval
  performance_insights_enabled     = var.performance_insights_enabled
  replica_scale_max                = var.replica_scale_max
  replica_scale_min                = var.replica_scale_min
  replica_min                      = var.replica_min
  predefined_metric_type           = var.predefined_metric_type
  replica_scale_cpu                = var.replica_scale_cpu
  replica_scale_in_cooldown        = var.replica_scale_in_cooldown
  replica_scale_out_cooldown       = var.replica_scale_out_cooldown
  ram_memory_bytes                 = var.ram_memory_bytes
  tcp_keepalives_count             = var.tcp_keepalives_count
  tcp_keepalives_idle              = var.tcp_keepalives_idle
  tcp_keepalives_interval          = var.tcp_keepalives_interval
  random_page_cost                 = var.random_page_cost
  multitenant_tag                  = var.multitenant_tag
  creation_snapshot_arn            = var.creation_snapshot_arn
  enable_devops_guru               = var.enable_devops_guru
  log_min_duration_statement       = var.log_min_duration_statement
  allow_major_version_upgrade      = var.allow_major_version_upgrade
  enabled_cloudwatch_logs_exports  = var.enabled_cloudwatch_logs_exports
  kms_key_id                       = var.kms_key_id

  tags = {
    Owner       = "cloud-team"
    Terraform   = "true"
    Environment = var.environment
    Purpose     = "provisioning"
  }
}
