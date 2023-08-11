package dbfactory

import (
	"fmt"
	"strings"

	terraform "github.com/mattermost/mattermost-cloud-database-factory/internal/tools/terraform"
	"github.com/mattermost/mattermost-cloud-database-factory/model"
	"github.com/pkg/errors"
)

var templateDirMySQL = "terraform/aws/database-factory"
var templateDirPostgreSQL = "terraform/aws/database-factory-postgresql"

// InitProvisionCluster is used to call the ProvisionCluster function.
func InitProvisionCluster(cluster *model.Cluster) {
	err := ProvisionCluster(cluster)
	if err != nil {
		if isTerraformWarning(err) {
			// Handle Terraform warning (non-fatal error)
			logger.WithError(err).Warn("Terraform encountered a warning during deployment")
		} else {
			logger.WithError(err).Error("failed to deploy RDS Aurora cluster")
			err = sendMattermostErrorNotification(cluster, err, "The Database Factory failed to deploy RDS Aurora cluster")
			if err != nil {
				logger.WithError(err).Error("Failed to send Mattermost error notification")
			}
		}
	}
}

func InitDeleteCluster(cluster *model.Cluster) {
	err := DeleteCluster(cluster)
	if err != nil {
		if isTerraformWarning(err) {
			// Handle Terraform warning (non-fatal error)
			logger.WithError(err).Warn("Terraform encountered a warning during deletion")
		} else {
			// Handle other types of errors (fatal errors)
			logger.WithError(err).Error("failed to delete RDS Aurora cluster")
			err = sendMattermostErrorNotification(cluster, err, "The Database Factory failed to delete RDS Aurora cluster")
			if err != nil {
				logger.WithError(err).Error("Failed to send Mattermost error notification")
			}
		}
	}
}

// ProvisionCluster is used to initiate Terraform and either Apply or Plan Terraform for the RDS Cluster deployments.
func ProvisionCluster(cluster *model.Cluster) error {
	logger.Info("Initialising Terraform")
	stateObject := fmt.Sprintf("rds-cluster-multitenant-%s-%s", strings.Split(cluster.VPCID, "-")[1], cluster.ClusterID)

	var templateDir string
	if cluster.DBEngine == "mysql" {
		templateDir = templateDirMySQL
	} else {
		templateDir = templateDirPostgreSQL
	}

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
		err = sendMattermostNotification(cluster, "The Database Factory successfully deployed/updated an RDS Aurora cluster")
		if err != nil {
			logger.WithError(err).Error("Failed to send Mattermost error notification")
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

// DeleteCluster is used to initiate Terraform and apply the deletion plan for the RDS Cluster.
func DeleteCluster(cluster *model.Cluster) error {
	logger.Info("Initialising Terraform for cluster deletion")
	stateObject := fmt.Sprintf("rds-cluster-multitenant-%s-%s", strings.Split(cluster.VPCID, "-")[1], cluster.ClusterID)

	var templateDir string
	if cluster.DBEngine == "mysql" {
		templateDir = templateDirMySQL
	} else {
		templateDir = templateDirPostgreSQL
	}

	tf, err := terraform.New(templateDir, cluster.StateStore, logger)
	if err != nil {
		return errors.Wrap(err, "failed to initiate Terraform for cluster deletion")
	}

	err = tf.Init(stateObject)
	if err != nil {
		return errors.Wrap(err, "failed to run Terraform init for cluster deletion")
	}

	logger.Info("planning Terraform deletion")
	err = tf.PlanDeletion(cluster)
	if err != nil {
		return errors.Wrap(err, "failed to run Terraform plan for cluster deletion")
	}
	logger.Info("successfully planned Terraform deletion")

	if cluster.Apply {
		logger.Info("applying Terraform deletion plan")
		err = tf.ApplyDeletion(cluster)
		if err != nil {
			return errors.Wrap(err, "failed to run Terraform apply for cluster deletion")
		}
		logger.Info("successfully applied Terraform deletion plan")
		err = sendMattermostNotification(cluster, "The Database Factory successfully deleted an RDS Aurora cluster")
		if err != nil {
			logger.WithError(err).Error("Failed to send Mattermost error notification")
		}
		return nil
	}

	logger.Info("Terraform apply for cluster deletion not requested, no changes made")
	return nil
}

func isTerraformWarning(err error) bool {
	// Check if the error message contains keywords indicating a Terraform warning
	errorMessage := err.Error()

	// List of common Terraform warning keywords
	warningKeywords := []string{
		"Warning:",
		"Potential data loss:",
		"this backend configuration block will have no effect.",
	}

	// Check if any of the warning keywords are present in the error message
	for _, keyword := range warningKeywords {
		if strings.Contains(errorMessage, keyword) {
			return true // Error is a Terraform warning
		}
	}

	return false // Error is not a Terraform warning
}
