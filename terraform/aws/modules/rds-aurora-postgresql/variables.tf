variable "vpc_id" {}

variable "db_id" {}

variable "port" {}

variable "environment" {}

variable "name" {}

variable "engine" {}

variable "engine_version" {}

variable "username" {}

variable "password" {}

variable "final_snapshot_identifier_prefix" {}

variable "skip_final_snapshot" {}

variable "deletion_protection" {}

variable "backup_retention_period" {}

variable "preferred_backup_window" {}

variable "preferred_maintenance_window" {}

variable "storage_encrypted" {}

variable "apply_immediately" {}

variable "copy_tags_to_snapshot" {}

variable "enabled_cloudwatch_logs_exports" {}

variable "tags" {}

variable "instance_type" {}

variable "monitoring_interval" {}

variable "performance_insights_enabled" {}

variable "replica_scale_max" {}

variable "replica_scale_min" {}

variable "replica_min" {}

variable "predefined_metric_type" {}

variable "replica_scale_cpu" {}

variable "replica_scale_connections" {}

variable "replica_scale_in_cooldown" {}

variable "replica_scale_out_cooldown" {}

variable "max_postgresql_connections" {}

variable "max_postgresql_connections_map" {}

variable "ram_memory_bytes" {}

variable "memory_cache_proportion" {}

variable "memory_alarm_limit" {}
