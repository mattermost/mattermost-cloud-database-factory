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
  default     = "5432"
  description = "The port on which the DB accepts connections"
  type        = string
}

variable "engine" {
  default     = "aurora-postgresql"
  description = "The database engine to use"
  type        = string
}

variable "engine_version" {
  default     = "13.10"
  description = "The engine version to use"
  type        = string
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
  default     = true
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
}

variable "replica_scale_max" {
  default     = 15
  type        = number
  description = "Maximum number of replicas to scale up to."
}

variable "replica_scale_min" {
  default     = 1
  description = "Minimum number of replicas to scale down to"
  type        = number
}

# Overwritten by database factory
variable "replica_min" {
  default     = 3
  type        = number
  description = "Number of replicas to deploy initially with the RDS Cluster. This is managed by the database factory app."
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

variable "multitenant_tag" {
  default     = ""
  type        = string
  description = "The tag that will be applied and identify the type of multitenant DB cluster(multitenant-rds-dbproxy or multitenant-rds)."
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

variable "ram_memory_bytes" {
  default = {
    "db.t3.small"     = "2147483648"
    "db.t3.medium"    = "4294967296"
    "db.t3.large"     = "8589934592"
    "db.t4g.small"    = "2147483648"
    "db.t4g.medium"   = "4294967296"
    "db.t4g.large"    = "8589934592"
    "db.r5.large"     = "17179869184"
    "db.r5.xlarge"    = "34359738368"
    "db.r5.2xlarge"   = "68719476736"
    "db.r5.4xlarge"   = "137438953472"
    "db.r5.8xlarge"   = "274877906944"
    "db.r5.12xlarge"  = "412316860416"
    "db.r5.16xlarge"  = "549755813888"
    "db.r5.24xlarge"  = "824633720832"
    "db.r6g.large"    = "17179869184"
    "db.r6g.xlarge"   = "34359738368"
    "db.r6g.2xlarge"  = "68719476736"
    "db.r6g.4xlarge"  = "137438953472"
    "db.r6g.8xlarge"  = "274877906944"
    "db.r6g.12xlarge" = "412316860416"
    "db.r6g.16xlarge" = "549755813888"
    "db.r6g.24xlarge" = "824633720832"
  }
  type        = map(any)
  description = "The RAM memory of each instance type in Bytes. A change in this variable should be reflected in database factory vertical scaling main.go as well."
}


variable "tcp_keepalives_count" {
  default     = 5
  description = "Maximum number of TCP keepalive retransmits.Specifies the number of TCP keepalive messages that can be lost before the server's connection to the client is considered dead. A value of 0 (the default) selects the operating system's default."
  type        = number
}

variable "random_page_cost" {
  default     = 1.1
  description = "Sets the planner's estimate of the cost of a non-sequentially-fetched disk page. The default is 4.0. This value can be overridden for tables and indexes in a particular tablespace by setting the tablespace parameter of the same name."
  type        = number
}

variable "tcp_keepalives_idle" {
  default     = 5
  description = "Time between issuing TCP keepalives.Specifies the amount of time with no network activity after which the operating system should send a TCP keepalive message to the client. If this value is specified without units, it is taken as seconds. A value of 0 (the default) selects the operating system's default."
  type        = number
}

variable "tcp_keepalives_interval" {
  default     = 1
  description = "Time between TCP keepalive retransmits. Specifies the amount of time after which a TCP keepalive message that has not been acknowledged by the client should be retransmitted. If this value is specified without units, it is taken as seconds. A value of 0 (the default) selects the operating system's default."
  type        = number
}

variable "creation_snapshot_arn" {
  type        = string
  description = "The ARN of the snapshot to create from"
  default     = ""
}

variable "enable_devops_guru" {
  default     = false
  type        = string
  description = "Set it to true will enable AWS Devops Guru service for DB instances within the cluster."
}

variable "log_min_duration_statement" {
  default     = -1
  type        = number
  description = "The duration of each completed statement to be logged."
}

variable "allow_major_version_upgrade" {
  default     = false
  type        = bool
  description = "Enable to allow major engine version upgrades when changing engine versions"
} 