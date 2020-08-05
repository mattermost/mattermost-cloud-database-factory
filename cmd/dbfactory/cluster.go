package main

import (
	"encoding/json"
	"os"

	"github.com/mattermost/mattermost-cloud-database-factory/model"
	"github.com/pkg/errors"
	"github.com/spf13/cobra"
)

func init() {
	clusterCmd.PersistentFlags().String("server", "http://localhost:8077", "The DB factory server whose API will be queried.")

	clusterCreateCmd.Flags().String("vpc-id", "", "The VPC id to create a RDS Aurora Cluster")
	clusterCreateCmd.Flags().String("cluster-id", "", "A random 8 character identifier of the Aurora cluster")
	clusterCreateCmd.Flags().String("environment", "dev", "The environment used for the deployment. Can be dev, test, staging or prod")
	clusterCreateCmd.Flags().String("state-store", "terraform-database-factory-state-bucket-dev", "The s3 bucket to store the terraform state")
	clusterCreateCmd.Flags().Bool("apply", false, "If disabled, only a Terraform plan will run instead of Terraform apply")
	clusterCreateCmd.Flags().String("instance-type", "db.r5.large", "The instance type used for Aurora cluster replicas")
	clusterCreateCmd.Flags().String("backup-retention-period", "15", "The retention period for the DB instance backups")
	clusterCreateCmd.Flags().String("db-engine", "postgresql", "The database engine. Can be mysql or postgresql")
	clusterCreateCmd.Flags().String("max-connections", "auto", "The max connections allowed in the DB cluster. This is applicable only to PostgreSQL engine")
	clusterCreateCmd.Flags().String("replicas", "3", "The total number of write/read replicas.")

	clusterCmd.AddCommand(clusterCreateCmd)
}

var clusterCmd = &cobra.Command{
	Use:   "cluster",
	Short: "Manipulate RDS clusters managed by the database factory server.",
}

var clusterCreateCmd = &cobra.Command{
	Use:   "create",
	Short: "Create a RDS Aurora cluster.",
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
		maxConnections, _ := command.Flags().GetString("max-connections")
		replicas, _ := command.Flags().GetString("replicas")

		cluster, err := client.CreateCluster(&model.CreateClusterRequest{
			VPCID:                 vpcID,
			ClusterID:             clusterID,
			Environment:           environment,
			StateStore:            stateStore,
			Apply:                 apply,
			InstanceType:          instanceType,
			BackupRetentionPeriod: backupRetentionPeriod,
			DBEngine:              dbEngine,
			MaxConnections:        maxConnections,
			Replicas:              replicas,
		})
		if err != nil {
			return errors.Wrap(err, "failed to create RDS cluster")
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
