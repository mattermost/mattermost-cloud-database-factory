variable "vpc_id" {
  default = ""
  type    = string
}

variable "db_id" {
  default = ""
  type    = string
}

variable "environment" {
  default = ""
  type    = string
}

variable "port" {
  default = "5432"
  type    = string
}

variable "engine" {
  default = "aurora-postgresql"
  type    = string
}

variable "engine_version" {
  default = "11.7"
  type    = string
}

variable "username" {
  default = "mmcloud"
  type    = string
}

variable "password" {
  default     = ""
  type        = string
  description = "If empty a random password will be created for each RDS Cluster and stored in AWS Secret Management."
}

variable "final_snapshot_identifier_prefix" {
  default = "final"
  type    = string
}

variable "skip_final_snapshot" {
  default = false
  type    = bool
}

variable "deletion_protection" {
  default = true
  type    = bool
}

variable "backup_retention_period" {
  default = ""
  type    = string
}

variable "preferred_backup_window" {
  default = "02:00-03:00"
  type    = string
}

variable "preferred_maintenance_window" {
  default = "sun:05:00-sun:06:00"
  type    = string
}

variable "storage_encrypted" {
  default = true
  type    = bool
}

variable "apply_immediately" {
  default = true
  type    = bool
}

variable "copy_tags_to_snapshot" {
  default = true
  type    = bool
}

variable "enabled_cloudwatch_logs_exports" {
  default = ["postgresql"]
  type    = list(string)
}

variable "instance_type" {
  default = ""
  type    = string
}

variable "monitoring_interval" {
  default = 60
  type    = number
}

variable "performance_insights_enabled" {
  default = true
  type    = bool
}

variable "replica_scale_max" {
  default     = 15
  type        = number
  description = "Maximum number of replicas to scale up to."
}

variable "replica_scale_min" {
  default = 1
  type    = number
}

# Overwritten by database factory
variable "replica_min" {
  default     = 3
  type        = number
  description = "Number of replicas to deploy initially with the RDS Cluster. This is managed by the database factory app."
}

variable "predefined_metric_type" {
  default = "RDSReaderAverageDatabaseConnections"
  type    = string
}

variable "replica_scale_cpu" {
  default     = 70
  type        = number
  description = "Needs to be set when predefined_metric_type is RDSReaderAverageCPUUtilization"
}

# NOT IN USE. Currently the 50% of max_connections parameter is set as a limit.
variable "replica_scale_connections" {
  default     = 100000
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
  default = ""
  type = string
}

variable "max_postgresql_connections_map" {
  default = {
    "db.t3.medium" = "50000"
    "db.r5.large" = "50000"
    "db.r5.xlarge" = "120000"
    "db.r5.2xlarge" = "200000"
    "db.r5.4xlarge" = "250000"
    "db.r5.8xlarge" = "255000"
    "db.r5.12xlarge" = "262143"
    "db.r5.16xlarge" = "262143"
    "db.r5.24xlarge" = "262143"
  }
  type = map
}
