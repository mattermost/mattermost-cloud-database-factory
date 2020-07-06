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
  default = "3306"
  type    = string
}

variable "engine" {
  default = "aurora-mysql"
  type    = string
}

variable "engine_version" {
  default = "5.7.12"
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
  default = ["audit", "error", "general", "slowquery"]
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
  default = false
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

variable "replica_min" {
  default     = 3
  type        = number
  description = "Number of replicas to deploy initially with the RDS Cluster."
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


