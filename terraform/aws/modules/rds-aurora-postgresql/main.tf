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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
  }
}

locals {
  master_password              = var.password == "" ? random_password.master_password.result : var.password
  database_id                  = var.db_id == "" ? random_string.db_cluster_identifier.result : var.db_id
  max_connections              = var.ram_memory_bytes[var.instance_type] / 9531392
  performance_insights_enabled = var.environment == "prod" ? var.performance_insights_enabled : false
}

# Random string to use as master password unless one is specified
resource "random_password" "master_password" {
  length  = 16
  special = false
}

data "aws_iam_role" "enhanced_monitoring" {
  name = "rds-enhanced-monitoring-mattermost-cloud-${var.environment}-provisioning"
}

resource "aws_kms_key" "aurora_storage_key" {
  description             = format("rds-multitenant-storage-key-%s-%s", split("-", var.vpc_id)[1], local.database_id)
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "aurora_storage_alias" {
  name          = "alias/${format("rds-multitenant-storage-key-%s-%s", split("-", var.vpc_id)[1], local.database_id)}"
  target_key_id = aws_kms_key.aurora_storage_key.key_id
}

data "aws_security_group" "db_sg" {
  name = format("mattermost-cloud-%s-provisioning-%s-db-postgresql-sg", var.environment, join("", split(".", split("/", data.aws_vpc.provisioning_vpc.cidr_block)[0])))
}

data "aws_vpc" "provisioning_vpc" {
  id = var.vpc_id
}

resource "aws_rds_cluster" "provisioning_rds_cluster" {
  cluster_identifier               = format("rds-cluster-multitenant-%s-%s", split("-", var.vpc_id)[1], local.database_id)
  engine                           = var.engine
  engine_version                   = var.engine_version
  kms_key_id                       = aws_kms_key.aurora_storage_key.arn
  master_username                  = var.username
  master_password                  = local.master_password
  final_snapshot_identifier        = "${var.final_snapshot_identifier_prefix}-${format("rds-cluster-multitenant-%s-%s", split("-", var.vpc_id)[1], local.database_id)}"
  skip_final_snapshot              = var.skip_final_snapshot
  deletion_protection              = var.deletion_protection
  backup_retention_period          = var.backup_retention_period
  preferred_backup_window          = var.preferred_backup_window
  preferred_maintenance_window     = var.preferred_maintenance_window
  port                             = var.port
  db_subnet_group_name             = "mattermost-provisioner-db-${var.vpc_id}-postgresql"
  vpc_security_group_ids           = [data.aws_security_group.db_sg.id]
  storage_encrypted                = var.storage_encrypted
  apply_immediately                = var.apply_immediately
  db_cluster_parameter_group_name  = aws_rds_cluster_parameter_group.cluster_parameter_group_postgresql.id
  db_instance_parameter_group_name = aws_db_parameter_group.db_parameter_group_postgresql.id
  copy_tags_to_snapshot            = var.copy_tags_to_snapshot
  snapshot_identifier              = var.creation_snapshot_arn == "" ? null : var.creation_snapshot_arn
  allow_major_version_upgrade      = var.allow_major_version_upgrade
  enabled_cloudwatch_logs_exports  = var.enabled_cloudwatch_logs_exports

  tags = merge(
    {
      "Counter"                             = 0,
      "MultitenantDatabaseID"               = format("rds-cluster-multitenant-%s-%s", split("-", var.vpc_id)[1], local.database_id),
      "VpcID"                               = var.vpc_id,
      "DatabaseType"                        = var.multitenant_tag,
      "MattermostCloudInstallationDatabase" = "PostgreSQL/Aurora"
    },
    var.tags
  )
  lifecycle {
    ignore_changes = [
      tags["Counter"]
    ]
  }
}

resource "aws_rds_cluster_instance" "provisioning_rds_db_instance" {
  count                        = var.replica_min
  identifier                   = format("rds-db-instance-multitenant-%s-%s-%s", split("-", var.vpc_id)[1], local.database_id, (count.index + 1))
  cluster_identifier           = aws_rds_cluster.provisioning_rds_cluster.id
  engine                       = var.engine
  engine_version               = var.engine_version
  instance_class               = var.instance_type
  db_subnet_group_name         = "mattermost-provisioner-db-${var.vpc_id}-postgresql"
  db_parameter_group_name      = aws_db_parameter_group.db_parameter_group_postgresql.id
  preferred_maintenance_window = var.preferred_maintenance_window
  apply_immediately            = var.apply_immediately
  monitoring_role_arn          = data.aws_iam_role.enhanced_monitoring.arn
  monitoring_interval          = var.monitoring_interval
  promotion_tier               = count.index + 1
  performance_insights_enabled = local.performance_insights_enabled

  tags = merge(
    {
      "DatabaseType"                        = var.multitenant_tag,
      "MattermostCloudInstallationDatabase" = "PostgreSQL/Aurora"
    },
    var.tags,
  [var.enable_devops_guru ? { "devops-guru-default" = replace("${aws_rds_cluster.provisioning_rds_cluster.cluster_identifier}-${count.index + 1}", "/rds-cluster/", "rds-db-instance") } : null]...)
  lifecycle {
    ignore_changes = [
      instance_class,
    ]
  }
}

/*
sleep 3 is a waiting time between tag Add/Remove and Devops Guru enable/disable.
This command will always run and "|| true will prevent it to broke when enabled_devops_guru is false and there's nothing to disable
The local exec is a temporary solution until terraform supports devops-guru https://github.com/hashicorp/terraform-provider-aws/issues/17919
*/
resource "null_resource" "enable_devops_guru" {
  count = var.replica_min
  provisioner "local-exec" {
    command = <<-EOF
      sleep 3 \
      && aws devops-guru update-resource-collection \
      --action ${var.enable_devops_guru == true ? "ADD" : "REMOVE"} \
      --resource-collection '{"Tags": [{"AppBoundaryKey": "devops-guru-default", "TagValues": ["${aws_rds_cluster.provisioning_rds_cluster.cluster_identifier}-${count.index + 1}"]}]}' \
      || true
EOF
  }
  depends_on = [
    aws_rds_cluster_instance.provisioning_rds_db_instance
  ]
  triggers = {
    enable_devops_guru = var.enable_devops_guru
  }
}

resource "random_string" "db_cluster_identifier" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_appautoscaling_target" "read_replica_count" {
  max_capacity       = var.replica_scale_max
  min_capacity       = var.replica_scale_min
  resource_id        = "cluster:${aws_rds_cluster.provisioning_rds_cluster.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "autoscaling_read_replica_count" {
  name               = format("rds-target-metric-%s-%s", split("-", var.vpc_id)[1], local.database_id)
  policy_type        = "TargetTrackingScaling"
  resource_id        = "cluster:${aws_rds_cluster.provisioning_rds_cluster.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.predefined_metric_type
    }

    scale_in_cooldown  = var.replica_scale_in_cooldown
    scale_out_cooldown = var.replica_scale_out_cooldown
    target_value       = var.predefined_metric_type == "RDSReaderAverageCPUUtilization" ? var.replica_scale_cpu : tonumber(local.max_connections) * 0.6
  }

  depends_on = [aws_appautoscaling_target.read_replica_count]
}

resource "aws_secretsmanager_secret" "master_password" {
  name = format("rds-cluster-multitenant-%s-%s", split("-", var.vpc_id)[1], local.database_id)
}

resource "aws_secretsmanager_secret_version" "master_password" {
  secret_id     = aws_secretsmanager_secret.master_password.id
  secret_string = local.master_password
}

resource "aws_db_parameter_group" "db_parameter_group_postgresql" {

  name_prefix = format("rds-cluster-multitenant-%s-%s-pg", split("-", var.vpc_id)[1], random_string.db_cluster_identifier.result)
  family      = "aurora-postgresql13"

  parameter {
    apply_method = "pending-reboot"
    name         = "max_connections"
    value        = "{DBInstanceClassMemory/9531392}"
  }

  parameter {
    name  = "random_page_cost"
    value = var.random_page_cost
  }

  parameter {
    name  = "tcp_keepalives_count"
    value = var.tcp_keepalives_count
  }

  parameter {
    name  = "tcp_keepalives_idle"
    value = var.tcp_keepalives_idle
  }

  parameter {
    name  = "tcp_keepalives_interval"
    value = var.tcp_keepalives_interval
  }

  parameter {
    name  = "log_min_duration_statement"
    value = var.environment == "prod" ? 2000 : var.log_min_duration_statement
  }

  tags = merge(
    {
      "MattermostCloudInstallationDatabase" = "PostgreSQL/Aurora",
      "MultitenantDatabaseID"               = format("rds-cluster-multitenant-%s-%s", split("-", var.vpc_id)[1], local.database_id)
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_parameter_group" "cluster_parameter_group_postgresql" {

  name_prefix = format("rds-cluster-multitenant-%s-%s-cluster-pg", split("-", var.vpc_id)[1], random_string.db_cluster_identifier.result)
  family      = "aurora-postgresql13"


  parameter {
    apply_method = "pending-reboot"
    name         = "max_connections"
    value        = "{DBInstanceClassMemory/9531392}"
  }

  parameter {
    name  = "random_page_cost"
    value = var.random_page_cost
  }

  parameter {
    name  = "tcp_keepalives_count"
    value = var.tcp_keepalives_count
  }

  parameter {
    name  = "tcp_keepalives_idle"
    value = var.tcp_keepalives_idle
  }

  parameter {
    name  = "tcp_keepalives_interval"
    value = var.tcp_keepalives_interval
  }

  parameter {
    name  = "log_min_duration_statement"
    value = var.environment == "prod" ? 2000 : var.log_min_duration_statement
  }

  tags = merge(
    {
      "MattermostCloudInstallationDatabase" = "PostgreSQL/Aurora",
      "MultitenantDatabaseID"               = format("rds-cluster-multitenant-%s-%s", split("-", var.vpc_id)[1], local.database_id)
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "rds-cluster-log-group" {
   name            = format("rds-cluster-multitenant-%s-%s/postgresql", split("-", var.vpc_id)[1], local.database_id)
   depends_on = [aws_rds_cluster.provisioning_rds_cluster]
 }
