package dbfactory

import (
	"fmt"
	"strings"

	terraform "github.com/mattermost/mattermost-cloud-database-factory/internal/tools/terraform"
	"github.com/mattermost/mattermost-cloud-database-factory/model"
	"github.com/pkg/errors"
)

var templateDir = "terraform/aws/database-factory"

// InitCreateCluster is used to call the CreateCluster function.
func InitCreateCluster(cluster *model.Cluster) {
	err := CreateCluster(cluster)
	if err != nil {
		logger.WithError(err).Error("failed to deploy RDS Aurora cluster")
		err = sendMattermostErrorNotification(cluster, err, "The Database Factory failed to deploy RDS Aurora cluster")
		if err != nil {
			logger.WithError(err).Error("Failed to send Mattermost error notification")
		}

	}
}

// CreateCluster is used to initiate Terraform and either Apply or Plan Terraform for the RDS Cluster deployments.
func CreateCluster(cluster *model.Cluster) error {
	logger.Info("Initialising Terraform")
	stateObject := fmt.Sprintf("rds-cluster-multitenant-%s-%s", strings.Split(cluster.VPCID, "-")[1], cluster.ClusterID)

	tf, err := terraform.New(templateDir, cluster.StateStore, logger)
	if err != nil {
		return errors.Wrap(err, "failed to initiate Terraform")
	}

	err = tf.Init(stateObject)
	if err != nil {
		return errors.Wrap(err, "failed to run Terraform init")
	}

	if cluster.Apply {
		logger.Info("applying Terraform template")
		err = tf.Apply(cluster)
		if err != nil {
			return errors.Wrap(err, "failed to run Terraform apply")
		}
		logger.Info("successfully applied Terraform template")
		err = sendMattermostNotification(cluster, "The Database Factory successfully deployed a new RDS Aurora cluster")
		if err != nil {
			return errors.Wrap(err, "failed tο send Mattermost notification")
		}
		return nil
	}
	err = tf.Plan(cluster)
	if err != nil {
		return errors.Wrap(err, "failed to run Terraform plan")
	}
	logger.Info("successfully ran Terraform plan")

	return nil
}
