variable "vpc_id" {
  description = "The VPC ID of the database cluster"
  type        = string
}

variable "db_id" {
  description = "The unique database ID of the cluster"
  type        = string
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = string
}

variable "environment" {
  description = "The name of the environment which will deploy to and will be added as a tag"
  type        = string
}

variable "engine" {
  description = "The database engine to use"
  type        = string
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
}

variable "username" {
  description = "Username for the master DB user"
  type        = string
}

variable "password" {
  type        = string
  description = "If empty a random password will be created for each RDS Cluster and stored in AWS Secret Management."
}

variable "final_snapshot_identifier_prefix" {
  description = "The prefix name of your final DB snapshot when this DB instance is deleted"
  type        = string
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
  type        = bool
}

variable "deletion_protection" {
  description = "Specifies if the DB instance should have deletion protection enabled"
  type        = bool
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = string
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter"
  type        = string
}

variable "preferred_maintenance_window" {
  description = "The window to perform maintenance in"
  type        = string
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted"
  type        = bool
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
  type        = bool
}

variable "copy_tags_to_snapshot" {
  description = "Copy all Cluster tags to snapshots"
  type        = bool
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to enable for exporting to CloudWatch logs"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(any)
}

variable "instance_type" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance"
  type        = number
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
}

variable "replica_scale_max" {
  type        = number
  description = "Maximum number of replicas to scale up to"
}

variable "replica_scale_min" {
  description = "Minimum number of replicas to scale down to"
  type        = number
}

variable "replica_min" {
  type        = number
  description = "Number of replicas to deploy initially with the RDS Cluster."
}

variable "predefined_metric_type" {
  description = "A predefined metric type"
  type        = string
}

variable "replica_scale_cpu" {
  type        = number
  description = "Needs to be set when predefined_metric_type is RDSReaderAverageCPUUtilization"
}

variable "replica_scale_connections" {
  type        = number
  description = "Needs to be set when predefined_metric_type is RDSReaderAverageDatabaseConnections"
}

variable "replica_scale_in_cooldown" {
  type        = number
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
}

variable "replica_scale_out_cooldown" {
  type        = number
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
}

variable "ram_memory_bytes" {
  type        = map(any)
  description = "The RAM memory of each instance type in Bytes. A change in this variable should be reflected in database factory vertical scaling main.go as well."
}

variable "random_page_cost" {
  description = "Sets the planner's estimate of the cost of a non-sequentially-fetched disk page. The default is 4.0. This value can be overridden for tables and indexes in a particular tablespace by setting the tablespace parameter of the same name."
  type        = number
}

variable "memory_cache_proportion" {
  description = "Proportion of memory that is used for cache. By default it is 75%. A change in this variable should be reflected in database factory vertical scaling main.go as well."
  type        = number
}

variable "connections_safety_percentage" {
  description = "Percentage of max connections that when reached should trigger vertical scaling."
  type        = number
}

variable "memory_alarm_limit" {
  description = "Limit to trigger memory alarm. Number in Bytes (100MB)"
  type        = string
}

variable "tcp_keepalives_count" {
  description = "Maximum number of TCP keepalive retransmits.Specifies the number of TCP keepalive messages that can be lost before the server's connection to the client is considered dead. A value of 0 (the default) selects the operating system's default."
  type        = number
}

variable "tcp_keepalives_idle" {
  description = "Time between issuing TCP keepalives.Specifies the amount of time with no network activity after which the operating system should send a TCP keepalive message to the client. If this value is specified without units, it is taken as seconds. A value of 0 (the default) selects the operating system's default."
  type        = number
}

variable "tcp_keepalives_interval" {
  description = "Time between TCP keepalive retransmits. Specifies the amount of time after which a TCP keepalive message that has not been acknowledged by the client should be retransmitted. If this value is specified without units, it is taken as seconds. A value of 0 (the default) selects the operating system's default."
  type        = number
}

variable "multitenant_tag" {
  type        = string
  description = "The tag that will be applied and identify the type of multitenant DB cluster(multitenant-rds-dbproxy or multitenant-rds)."
}
