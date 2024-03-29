<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds_setup"></a> [rds\_setup](#module\_rds\_setup) | ../modules/rds-aurora-postgresql | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Enable to allow major engine version upgrades when changing engine versions | `bool` | `false` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window | `bool` | `true` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | The days to retain backups for | `string` | `""` | no |
| <a name="input_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#input\_copy\_tags\_to\_snapshot) | Copy all Cluster tags to snapshots | `bool` | `true` | no |
| <a name="input_creation_snapshot_arn"></a> [creation\_snapshot\_arn](#input\_creation\_snapshot\_arn) | The ARN of the snapshot to create from | `string` | `""` | no |
| <a name="input_db_id"></a> [db\_id](#input\_db\_id) | The unique database ID of the cluster | `string` | `""` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Specifies if the DB instance should have deletion protection enabled | `bool` | `true` | no |
| <a name="input_enable_devops_guru"></a> [enable\_devops\_guru](#input\_enable\_devops\_guru) | Set it to true will enable AWS Devops Guru service for DB instances within the cluster. | `string` | `false` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The database engine to use | `string` | `"aurora-postgresql"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The engine version to use | `string` | `"13.10"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment which will deploy to and will be added as a tag | `string` | `""` | no |
| <a name="input_final_snapshot_identifier_prefix"></a> [final\_snapshot\_identifier\_prefix](#input\_final\_snapshot\_identifier\_prefix) | The prefix name of your final DB snapshot when this DB instance is deleted | `string` | `"final"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type of the RDS instance | `string` | `""` | no |
| <a name="input_log_min_duration_statement"></a> [log\_min\_duration\_statement](#input\_log\_min\_duration\_statement) | The duration of each completed statement to be logged. | `number` | `-1` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance | `number` | `60` | no |
| <a name="input_multitenant_tag"></a> [multitenant\_tag](#input\_multitenant\_tag) | The tag that will be applied and identify the type of multitenant DB cluster(multitenant-rds-dbproxy or multitenant-rds). | `string` | `""` | no |
| <a name="input_password"></a> [password](#input\_password) | If empty a random password will be created for each RDS Cluster and stored in AWS Secret Management. | `string` | `""` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Specifies whether Performance Insights are enabled | `bool` | `true` | no |
| <a name="input_port"></a> [port](#input\_port) | The port on which the DB accepts connections | `string` | `"5432"` | no |
| <a name="input_predefined_metric_type"></a> [predefined\_metric\_type](#input\_predefined\_metric\_type) | A predefined metric type | `string` | `"RDSReaderAverageDatabaseConnections"` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter | `string` | `"02:00-03:00"` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | The window to perform maintenance in | `string` | `"sat:09:00-sat:11:00"` | no |
| <a name="input_ram_memory_bytes"></a> [ram\_memory\_bytes](#input\_ram\_memory\_bytes) | The RAM memory of each instance type in Bytes. A change in this variable should be reflected in database factory vertical scaling main.go as well. | `map(any)` | <pre>{<br>  "db.r5.12xlarge": "412316860416",<br>  "db.r5.16xlarge": "549755813888",<br>  "db.r5.24xlarge": "824633720832",<br>  "db.r5.2xlarge": "68719476736",<br>  "db.r5.4xlarge": "137438953472",<br>  "db.r5.8xlarge": "274877906944",<br>  "db.r5.large": "17179869184",<br>  "db.r5.xlarge": "34359738368",<br>  "db.r6g.12xlarge": "412316860416",<br>  "db.r6g.16xlarge": "549755813888",<br>  "db.r6g.24xlarge": "824633720832",<br>  "db.r6g.2xlarge": "68719476736",<br>  "db.r6g.4xlarge": "137438953472",<br>  "db.r6g.8xlarge": "274877906944",<br>  "db.r6g.large": "17179869184",<br>  "db.r6g.xlarge": "34359738368",<br>  "db.t3.large": "8589934592",<br>  "db.t3.medium": "4294967296",<br>  "db.t3.small": "2147483648",<br>  "db.t4g.large": "8589934592",<br>  "db.t4g.medium": "4294967296",<br>  "db.t4g.small": "2147483648"<br>}</pre> | no |
| <a name="input_random_page_cost"></a> [random\_page\_cost](#input\_random\_page\_cost) | Sets the planner's estimate of the cost of a non-sequentially-fetched disk page. The default is 4.0. This value can be overridden for tables and indexes in a particular tablespace by setting the tablespace parameter of the same name. | `number` | `1.1` | no |
| <a name="input_replica_min"></a> [replica\_min](#input\_replica\_min) | Number of replicas to deploy initially with the RDS Cluster. This is managed by the database factory app. | `number` | `3` | no |
| <a name="input_replica_scale_cpu"></a> [replica\_scale\_cpu](#input\_replica\_scale\_cpu) | Needs to be set when predefined\_metric\_type is RDSReaderAverageCPUUtilization | `number` | `70` | no |
| <a name="input_replica_scale_in_cooldown"></a> [replica\_scale\_in\_cooldown](#input\_replica\_scale\_in\_cooldown) | Cooldown in seconds before allowing further scaling operations after a scale in | `number` | `300` | no |
| <a name="input_replica_scale_max"></a> [replica\_scale\_max](#input\_replica\_scale\_max) | Maximum number of replicas to scale up to. | `number` | `15` | no |
| <a name="input_replica_scale_min"></a> [replica\_scale\_min](#input\_replica\_scale\_min) | Minimum number of replicas to scale down to | `number` | `1` | no |
| <a name="input_replica_scale_out_cooldown"></a> [replica\_scale\_out\_cooldown](#input\_replica\_scale\_out\_cooldown) | Cooldown in seconds before allowing further scaling operations after a scale out | `number` | `300` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB instance is deleted | `bool` | `false` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the DB cluster is encrypted | `bool` | `true` | no |
| <a name="input_tcp_keepalives_count"></a> [tcp\_keepalives\_count](#input\_tcp\_keepalives\_count) | Maximum number of TCP keepalive retransmits.Specifies the number of TCP keepalive messages that can be lost before the server's connection to the client is considered dead. A value of 0 (the default) selects the operating system's default. | `number` | `5` | no |
| <a name="input_tcp_keepalives_idle"></a> [tcp\_keepalives\_idle](#input\_tcp\_keepalives\_idle) | Time between issuing TCP keepalives.Specifies the amount of time with no network activity after which the operating system should send a TCP keepalive message to the client. If this value is specified without units, it is taken as seconds. A value of 0 (the default) selects the operating system's default. | `number` | `5` | no |
| <a name="input_tcp_keepalives_interval"></a> [tcp\_keepalives\_interval](#input\_tcp\_keepalives\_interval) | Time between TCP keepalive retransmits. Specifies the amount of time after which a TCP keepalive message that has not been acknowledged by the client should be retransmitted. If this value is specified without units, it is taken as seconds. A value of 0 (the default) selects the operating system's default. | `number` | `1` | no |
| <a name="input_username"></a> [username](#input\_username) | n/a | `string` | `"mmcloud"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID of the database cluster | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->