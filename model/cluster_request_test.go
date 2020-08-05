package model_test

import (
	"testing"

	"github.com/mattermost/mattermost-cloud-database-factory/model"
	"github.com/stretchr/testify/assert"
)

func TestProvisionClusterRequestValid(t *testing.T) {
	var testCases = []struct {
		testName     string
		request      *model.ProvisionClusterRequest
		requireError bool
	}{
		{"invalid vpcid", &model.ProvisionClusterRequest{VPCID: ""}, true},
		{"invalid environment", &model.ProvisionClusterRequest{Environment: ""}, true},
		{"invalid statestore", &model.ProvisionClusterRequest{StateStore: ""}, true},
	}

	for _, tc := range testCases {
		t.Run(tc.testName, func(t *testing.T) {

			if tc.requireError {
				assert.Error(t, tc.request.Validate())
			} else {
				assert.NoError(t, tc.request.Validate())
			}
		})
	}
}
