variable "vpc_id" {
  default     = ""
  description = "The VPC ID of the database cluster"
  type        = string
}

variable "db_id" {
  default     = ""
  description = "The unique database ID of the cluster"
  type        = string
}

variable "environment" {
  default     = ""
  description = "The name of the environment which will deploy to and will be added as a tag"
  type        = string
}

variable "port" {
  default     = "3306"
  description = "The port on which the DB accepts connections"
  type        = string
}

variable "engine" {
  default     = "aurora-mysql"
  description = "The database engine to use"
  type        = string
}

variable "engine_version" {
  default     = "5.7.12"
  description = "The engine version to use"
  type        = string
}

variable "username" {
  default     = "mmcloud"
  description = "Username for the master DB user"
  type        = string
}

variable "password" {
  default     = ""
  type        = string
  description = "If empty a random password will be created for each RDS Cluster and stored in AWS Secret Management."
}

variable "final_snapshot_identifier_prefix" {
  default     = "final"
  description = "The prefix name of your final DB snapshot when this DB instance is deleted"
  type        = string
}

variable "skip_final_snapshot" {
  default     = false
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
  type        = bool
}

variable "deletion_protection" {
  default     = true
  description = "Specifies if the DB instance should have deletion protection enabled"
  type        = bool
}

variable "backup_retention_period" {
  default     = ""
  description = "The days to retain backups for"
  type        = string
}

variable "preferred_backup_window" {
  default     = "02:00-03:00"
  description = "The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter"
  type        = string
}

variable "preferred_maintenance_window" {
  default     = "sat:09:00-sat:11:00"
  description = "The window to perform maintenance in"
  type        = string
}

variable "storage_encrypted" {
  default     = true
  description = "Specifies whether the DB cluster is encrypted"
  type        = bool
}

variable "apply_immediately" {
  default     = true
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
  type        = bool
}

variable "copy_tags_to_snapshot" {
  default     = true
  description = "Copy all Cluster tags to snapshots"
  type        = bool
}

variable "enabled_cloudwatch_logs_exports" {
  default     = ["audit", "error", "general", "slowquery"]
  description = "Set of log types to enable for exporting to CloudWatch logs"
  type        = list(string)
}

variable "instance_type" {
  default     = ""
  description = "The instance type of the RDS instance"
  type        = string
}

variable "monitoring_interval" {
  default     = 60
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance"
  type        = number
}

variable "performance_insights_enabled" {
  default     = false
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
}

variable "replica_scale_max" {
  default     = 15
  type        = number
  description = "Maximum number of replicas to scale up to"
}

variable "replica_scale_min" {
  default     = 1
  description = "Minimum number of replicas to scale down to"
  type        = number
}

variable "replica_min" {
  default     = 3
  type        = number
  description = "Number of replicas to deploy initially with the RDS Cluster."
}

variable "predefined_metric_type" {
  default     = "RDSReaderAverageDatabaseConnections"
  description = "A predefined metric type"
  type        = string
}

variable "replica_scale_cpu" {
  default     = 70
  type        = number
  description = "Needs to be set when predefined_metric_type is RDSReaderAverageCPUUtilization"
}

variable "replica_scale_connections" {
  default     = 10000
  type        = number
  description = "Needs to be set when predefined_metric_type is RDSReaderAverageDatabaseConnections"
}

variable "replica_scale_in_cooldown" {
  default     = 300
  type        = number
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
}

variable "replica_scale_out_cooldown" {
  default     = 300
  type        = number
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
}

variable "max_postgresql_connections" {
  type = string
}

variable "creation_snapshot_arn" {
  type        = string
  description = "The ARN of the snapshot to create from"
  default     = ""
}
