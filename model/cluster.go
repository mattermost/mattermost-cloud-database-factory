package model

import (
	"encoding/json"
	"io"
)

// Cluster represents a RDS Aurora cluster.
type Cluster struct {
	VPCID                 string
	ClusterID             string
	Environment           string
	StateStore            string
	Apply                 bool
	InstanceType          string
	BackupRetentionPeriod string
}

// ClusterFromReader decodes a json-encoded cluster from the given io.Reader.
func ClusterFromReader(reader io.Reader) (*Cluster, error) {
	cluster := Cluster{}
	decoder := json.NewDecoder(reader)
	err := decoder.Decode(&cluster)
	if err != nil && err != io.EOF {
		return nil, err
	}

	return &cluster, nil
}
