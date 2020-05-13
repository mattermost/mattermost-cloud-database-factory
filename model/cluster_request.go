package model

import (
	"encoding/json"
	"io"
	"strings"

	"github.com/pkg/errors"
)

// CreateClusterRequest specifies the parameters for a new cluster.
type CreateClusterRequest struct {
	VPCID                 string `json:"vpcID,omitempty"`
	ClusterID             string `json:"ClusterID,omitempty"`
	Environment           string `json:"environment,omitempty"`
	StateStore            string `json:"stateStore,omitempty"`
	Apply                 bool   `json:"apply,omitempty"`
	InstanceType          string `json:"instanceType"`
	BackupRetentionPeriod string `json:"backupRetentionPeriod"`
}

// NewCreateClusterRequestFromReader decodes the request and returns after validation and setting the defaults.
func NewCreateClusterRequestFromReader(reader io.Reader) (*CreateClusterRequest, error) {
	var createClusterRequest CreateClusterRequest
	err := json.NewDecoder(reader).Decode(&createClusterRequest)
	if err != nil && err != io.EOF {
		return nil, errors.Wrap(err, "failed to decode create cluster request")
	}

	err = createClusterRequest.Validate()
	if err != nil {
		return nil, errors.Wrap(err, "create cluster request failed validation")
	}
	createClusterRequest.SetDefaults()

	return &createClusterRequest, nil
}

// Validate validates the values of a cluster create request.
func (request *CreateClusterRequest) Validate() error {
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

// SetDefaults sets the default values for a cluster create request.
func (request *CreateClusterRequest) SetDefaults() {
	if request.ClusterID == "" {
		request.ClusterID = StringWithCharset(8, strings.Split(request.VPCID, "-")[1])
	}

	if request.InstanceType == "" {
		request.InstanceType = "db.r4.large"
	}

	if request.BackupRetentionPeriod == "" {
		request.BackupRetentionPeriod = "15"
	}
}
