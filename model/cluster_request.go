package model

import (
	"encoding/json"
	"io"
	"strings"

	"github.com/pkg/errors"
)

// ProvisionClusterRequest specifies the parameters for a new cluster.
type ProvisionClusterRequest struct {
	VPCID                 string `json:"vpcID,omitempty"`
	ClusterID             string `json:"clusterID,omitempty"`
	Environment           string `json:"environment,omitempty"`
	StateStore            string `json:"stateStore,omitempty"`
	Apply                 bool   `json:"apply,omitempty"`
	InstanceType          string `json:"instanceType"`
	BackupRetentionPeriod string `json:"backupRetentionPeriod"`
	DBEngine              string `json:"dbEngine"`
	MaxConnections        string `json:"maxConnections,omitempty"`
	Replicas              string `json:"replicas"`
}

// NewProvisionClusterRequestFromReader decodes the request and returns after validation and setting the defaults.
func NewProvisionClusterRequestFromReader(reader io.Reader) (*ProvisionClusterRequest, error) {
	var provisionClusterRequest ProvisionClusterRequest
	err := json.NewDecoder(reader).Decode(&provisionClusterRequest)
	if err != nil && err != io.EOF {
		return nil, errors.Wrap(err, "failed to decode provision cluster request")
	}

	err = provisionClusterRequest.Validate()
	if err != nil {
		return nil, errors.Wrap(err, "provision cluster request failed validation")
	}
	provisionClusterRequest.SetDefaults()

	return &provisionClusterRequest, nil
}

// Validate validates the values of a cluster provision request.
func (request *ProvisionClusterRequest) Validate() error {
	if request.VPCID == "" {
		return errors.Errorf("vpc id cannot be empty")
	}

	if request.Environment == "" {
		return errors.Errorf("environment cannot be empty")
	}

	if request.StateStore == "" {
		return errors.Errorf("state store cannot be empty")
	}

	return nil
}

// SetDefaults sets the default values for a cluster provision request.
func (request *ProvisionClusterRequest) SetDefaults() {
	if request.ClusterID == "" {
		request.ClusterID = StringWithCharset(8, strings.Split(request.VPCID, "-")[1])
	}

	if request.InstanceType == "" {
		request.InstanceType = "db.r5.large"
	}

	if request.BackupRetentionPeriod == "" {
		request.BackupRetentionPeriod = "15"
	}

	if request.DBEngine == "" {
		request.DBEngine = "postgresql"
	}

	if request.MaxConnections == "" {
		request.MaxConnections = "auto"
	}

	if request.Replicas == "" {
		request.Replicas = "3"
	}
}
