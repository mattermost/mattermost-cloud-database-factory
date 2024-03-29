package main

import (
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/rds"
	"github.com/aws/aws-sdk-go/service/rds/rdsiface"
	"github.com/mattermost/mattermost-cloud-database-factory/model"
	"github.com/olekukonko/tablewriter"
	"github.com/pkg/errors"
	"github.com/spf13/cobra"
)

func init() {
	clusterCmd.PersistentFlags().String("server", "http://localhost:8077", "The DB factory server whose API will be queried.")

	clusterDeleteCmd.Flags().String("vpc-id", "", "The VPC id to provision a RDS Aurora Cluster")
	clusterDeleteCmd.Flags().String("cluster-id", "", "A random 8 character identifier of the Aurora cluster")
	clusterDeleteCmd.Flags().String("environment", "dev", "The environment used for the deployment. Can be dev, test, staging or prod")
	clusterDeleteCmd.Flags().String("state-store", "terraform-database-factory-state-bucket-dev", "The s3 bucket to store the terraform state")
	clusterDeleteCmd.Flags().Bool("apply", false, "If disabled, only a Terraform plan will run instead of Terraform apply")
	clusterDeleteCmd.Flags().String("instance-type", "db.r5.large", "The instance type used for Aurora cluster replicas")
	clusterDeleteCmd.Flags().String("backup-retention-period", "15", "The retention period for the DB instance backups")
	clusterDeleteCmd.Flags().String("db-engine", "postgres", "The database engine. Can be mysql or postgres")
	clusterDeleteCmd.Flags().String("replicas", "3", "The total number of write/read replicas.")
	clusterDeleteCmd.Flags().Bool("dbproxy", true, "If enabled the multitenant DB cluster will be used with a DB proxy.")
	clusterDeleteCmd.Flags().String("creation-snapshot-arn", "", "The ARN of the snapshot to use for the DB cluster (default \"\")")
	clusterDeleteCmd.Flags().Bool("devops-guru", false, "Enable the AWS service Devops Guru to all database instances within a cluster.")
	clusterDeleteCmd.Flags().Bool("allow-major-version-upgrade", false, "Enable to allow major engine version upgrades when changing engine versions.")
	clusterDeleteCmd.Flags().String("kms-key-id", "", "The ARN key to encrypt the storage and performance insights")

	clusterProvisionCmd.Flags().String("vpc-id", "", "The VPC id to provision a RDS Aurora Cluster")
	clusterProvisionCmd.Flags().String("cluster-id", "", "A random 8 character identifier of the Aurora cluster")
	clusterProvisionCmd.Flags().String("environment", "dev", "The environment used for the deployment. Can be dev, test, staging or prod")
	clusterProvisionCmd.Flags().String("state-store", "terraform-database-factory-state-bucket-dev", "The s3 bucket to store the terraform state")
	clusterProvisionCmd.Flags().Bool("apply", false, "If disabled, only a Terraform plan will run instead of Terraform apply")
	clusterProvisionCmd.Flags().String("instance-type", "db.r5.large", "The instance type used for Aurora cluster replicas")
	clusterProvisionCmd.Flags().String("backup-retention-period", "15", "The retention period for the DB instance backups")
	clusterProvisionCmd.Flags().String("db-engine", "postgres", "The database engine. Can be mysql or postgres")
	clusterProvisionCmd.Flags().String("replicas", "3", "The total number of write/read replicas.")
	clusterProvisionCmd.Flags().Bool("dbproxy", true, "If enabled the multitenant DB cluster will be used with a DB proxy.")
	clusterProvisionCmd.Flags().String("creation-snapshot-arn", "", "The ARN of the snapshot to use for the DB cluster (default \"\")")
	clusterProvisionCmd.Flags().Bool("devops-guru", false, "Enable the AWS service Devops Guru to all database instances within a cluster.")
	clusterProvisionCmd.Flags().Bool("allow-major-version-upgrade", false, "Enable to allow major engine version upgrades when changing engine versions.")
	clusterProvisionCmd.Flags().String("kms-key-id", "", "The ARN key to encrypt the storage and performance insights")
	clusterProvisionCmd.Flags().Bool("deletion-protection", true, "Disable to allow cluster deletion.")

	clusterCmd.AddCommand(clusterProvisionCmd)
	clusterCmd.AddCommand(clusterDeleteCmd)

	sess, err := session.NewSession()
	if err != nil {
		logger.WithError(err).Error()
		return
	}
	clusterCmd.AddCommand(newSearchCommand(rds.New(sess)))
}

var clusterCmd = &cobra.Command{
	Use:   "cluster",
	Short: "Manipulate RDS clusters managed by the database factory server.",
}

var clusterProvisionCmd = &cobra.Command{
	Use:   "provision",
	Short: "Provision a RDS Aurora cluster.",
	RunE: func(command *cobra.Command, args []string) error {
		command.SilenceUsage = true
		serverAddress, _ := command.Flags().GetString("server")
		client := model.NewClient(serverAddress)

		vpcID, _ := command.Flags().GetString("vpc-id")
		clusterID, _ := command.Flags().GetString("cluster-id")
		environment, _ := command.Flags().GetString("environment")
		stateStore, _ := command.Flags().GetString("state-store")
		apply, _ := command.Flags().GetBool("apply")
		instanceType, _ := command.Flags().GetString("instance-type")
		backupRetentionPeriod, _ := command.Flags().GetString("backup-retention-period")
		dbEngine, _ := command.Flags().GetString("db-engine")
		replicas, _ := command.Flags().GetString("replicas")
		dbProxy, _ := command.Flags().GetBool("dbproxy")
		creationSnapshotARN, _ := command.Flags().GetString("creation-snapshot-arn")
		enableDevopsGuru, _ := command.Flags().GetBool("devops-guru")
		allowMajorVersionUpgrade, _ := command.Flags().GetBool("allow-major-version-upgrade")
		kmsKeyID, _ := command.Flags().GetString("kms-key-id")
		deletionProtection, _ := command.Flags().GetBool("deletion-protection")

		cluster, err := client.ProvisionCluster(&model.ProvisionClusterRequest{
			VPCID:                    vpcID,
			ClusterID:                clusterID,
			Environment:              environment,
			StateStore:               stateStore,
			Apply:                    apply,
			InstanceType:             instanceType,
			BackupRetentionPeriod:    backupRetentionPeriod,
			DBEngine:                 dbEngine,
			Replicas:                 replicas,
			DBProxy:                  dbProxy,
			CreationSnapshotARN:      creationSnapshotARN,
			EnableDevopsGuru:         enableDevopsGuru,
			AllowMajorVersionUpgrade: allowMajorVersionUpgrade,
			KMSKeyID:                 kmsKeyID,
			DeletionProtection:       deletionProtection,
		})
		if err != nil {
			return errors.Wrap(err, "failed to provision RDS cluster")
		}
		err = printJSON(cluster)
		if err != nil {
			return err
		}

		return nil
	},
}

var clusterDeleteCmd = &cobra.Command{
	Use:   "delete",
	Short: "Delete a RDS Aurora cluster.",
	RunE: func(command *cobra.Command, args []string) error {
		command.SilenceUsage = true
		serverAddress, _ := command.Flags().GetString("server")
		client := model.NewClient(serverAddress)

		vpcID, _ := command.Flags().GetString("vpc-id")
		clusterID, _ := command.Flags().GetString("cluster-id")
		environment, _ := command.Flags().GetString("environment")
		stateStore, _ := command.Flags().GetString("state-store")
		apply, _ := command.Flags().GetBool("apply")
		instanceType, _ := command.Flags().GetString("instance-type")
		backupRetentionPeriod, _ := command.Flags().GetString("backup-retention-period")
		dbEngine, _ := command.Flags().GetString("db-engine")
		replicas, _ := command.Flags().GetString("replicas")
		dbProxy, _ := command.Flags().GetBool("dbproxy")
		creationSnapshotARN, _ := command.Flags().GetString("creation-snapshot-arn")
		enableDevopsGuru, _ := command.Flags().GetBool("devops-guru")
		allowMajorVersionUpgrade, _ := command.Flags().GetBool("allow-major-version-upgrade")
		kmsKeyID, _ := command.Flags().GetString("kms-key-id")

		cluster, err := client.DeleteCluster(&model.ProvisionClusterRequest{
			VPCID:                    vpcID,
			ClusterID:                clusterID,
			Environment:              environment,
			StateStore:               stateStore,
			Apply:                    apply,
			InstanceType:             instanceType,
			BackupRetentionPeriod:    backupRetentionPeriod,
			DBEngine:                 dbEngine,
			Replicas:                 replicas,
			DBProxy:                  dbProxy,
			CreationSnapshotARN:      creationSnapshotARN,
			EnableDevopsGuru:         enableDevopsGuru,
			AllowMajorVersionUpgrade: allowMajorVersionUpgrade,
			KMSKeyID:                 kmsKeyID,
		})
		if err != nil {
			return errors.Wrap(err, "failed to delete RDS cluster")
		}
		err = printJSON(cluster)
		if err != nil {
			return err
		}

		return nil
	},
}

func printJSON(data interface{}) error {
	encoder := json.NewEncoder(os.Stdout)
	encoder.SetIndent("", "    ")
	return encoder.Encode(data)
}

// searchOpts the options to be used for the search command
type searchOpts struct {
	tags   map[string]string
	engine string
	limit  int64
}

// newSearchCommand adds a subcommand in cluster in order to be
// able to search by given tags.
// - Example -
// dbfactory cluster -t 'DatabaseType=multitenant-rds'
func newSearchCommand(svc rdsiface.RDSAPI) *cobra.Command {
	opts := searchOpts{}

	cmd := &cobra.Command{
		Use:   "get",
		Short: "Returns the RDS clusters which has been created by database factory server.",
		RunE: func(command *cobra.Command, args []string) error {
			input := &rds.DescribeDBClustersInput{
				MaxRecords: aws.Int64(opts.limit),
			}

			instanceType := ""
			result, err := svc.DescribeDBClusters(input)
			if err != nil {
				return err
			}
			table := tablewriter.NewWriter(os.Stdout)
			table.SetHeader([]string{"VPC", "Database ID", "Engine", "Engine Version", "Backup Retention", "Instance Type", "Database Type"})

			for _, r := range result.DBClusters {
				group, err := svc.DescribeDBSubnetGroups(&rds.DescribeDBSubnetGroupsInput{
					DBSubnetGroupName: r.DBSubnetGroup,
				})
				if err != nil {
					return errors.Wrapf(err, "failed to describe DBSubnetGroup: %s", *r.DBSubnetGroup)
				}
				databaseType := ""
				for _, tag := range r.TagList {
					if *tag.Key == "DatabaseType" {
						databaseType = *tag.Value
					}
				}
				if len(r.DBClusterMembers) > 0 {
					instance, err := svc.DescribeDBInstances(&rds.DescribeDBInstancesInput{
						DBInstanceIdentifier: r.DBClusterMembers[0].DBInstanceIdentifier,
					})
					instanceType = fmt.Sprint(*instance.DBInstances[0].DBInstanceClass)
					if err != nil {
						return errors.Wrapf(err, "failed to describe DBInstance: %s", *r.DBClusterMembers[0])
					}
				}
				if !contains(r.TagList, opts.tags) {
					continue
				}
				if *r.Engine != strings.ToLower(strings.TrimSpace(opts.engine)) {
					continue
				}
				table.Append([]string{
					*group.DBSubnetGroups[0].VpcId,
					*r.DBClusterIdentifier,
					*r.Engine,
					*r.EngineVersion,
					fmt.Sprint(*r.BackupRetentionPeriod),
					instanceType,
					databaseType,
				})
			}

			table.Render()
			return nil
		},
	}
	cmd.Flags().StringToStringVarP(&opts.tags, "tags", "t", map[string]string{}, "The tags as key/value which will be used for filtering.")
	cmd.Flags().StringVarP(&opts.engine, "engine", "e", "aurora-postgresql", "The Engine type of RDS.")
	cmd.Flags().Int64VarP(&opts.limit, "limit", "l", 100, "The number of results which can be returned back.")
	return cmd
}

func contains(tagsList []*rds.Tag, tags map[string]string) bool {
	var found int
	for _, t := range tagsList {
		if val, ok := tags[*t.Key]; ok && *t.Value == val {
			found++
		}
	}
	return found == len(tags)
}
