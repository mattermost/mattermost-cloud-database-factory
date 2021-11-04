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
  default = "11.9"
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
  default = "sat:09:00-sat:11:00"
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

variable "multitenant_tag" {
  default     = ""
  type        = string
  description = "The tag that will be applied and identify the type of multitenant DB cluster(multitenant-rds-dbproxy or multitenant-rds)."
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
  type    = string
}

variable "max_postgresql_connections_map" {
  default = {
    "db.t3.medium"   = "415"
    "db.r5.large"    = "1675"
    "db.r5.xlarge"   = "3355"
    "db.r5.2xlarge"  = "6710"
    "db.r5.4xlarge"  = "13425"
    "db.r5.8xlarge"  = "26855"
    "db.r5.12xlarge" = "40285"
    "db.r5.16xlarge" = "53715"
    "db.r5.24xlarge" = "80575"
  }
  type = map(any)
}

variable "ram_memory_bytes" {
  default = {
    "db.t3.medium"   = "4294967296"
    "db.r5.large"    = "17179869184"
    "db.r5.xlarge"   = "34359738368"
    "db.r5.2xlarge"  = "68719476736"
    "db.r5.4xlarge"  = "137438953472"
    "db.r5.8xlarge"  = "274877906944"
    "db.r5.12xlarge" = "412316860416"
    "db.r5.16xlarge" = "549755813888"
    "db.r5.24xlarge" = "824633720832"
  }
  type        = map(any)
  description = "The RAM memory of each instance type in Bytes. A change in this variable should be reflected in database factory vertical scaling main.go as well."
}

variable "memory_alarm_limit" {
  default     = "100000000"
  description = "Limit to trigger memory alarm. Number in Bytes (100MB)"
  type        = string
}

variable "memory_cache_proportion" {
  default     = 0.75
  description = "Proportion of memory that is used for cache. By default it is 75%. A change in this variable should be reflected in database factory vertical scaling main.go as well."
  type        = number
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

variable "lambda_arn" {
  default     = ""
  description = "Lambda logs-to-opensearch ARN"
  type        = string
}

variable "lambda_name" {
  default     = "logs-to-opensearch"
  description = "Lambda which ships logs to opensearch"
  type        = string
}
variable "cwl_endpoint" {
  default     = "logs.us-east-1.amazonaws.com"
  description = "Cloudwatch Logs endpoint"
  type        = string
}

