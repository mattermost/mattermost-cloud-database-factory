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
		{
			testName: "invalid vpcid",
			request: &model.ProvisionClusterRequest{
				VPCID: "",
			},
			requireError: true,
		},
		{
			testName: "invalid environment",
			request: &model.ProvisionClusterRequest{
				Environment: "",
			},
			requireError: true},
		{
			testName: "invalid statestore",
			request: &model.ProvisionClusterRequest{
				StateStore: "",
			},
			requireError: true,
		},
		{
			testName:     "invalid KMS key ID",
			request:      &model.ProvisionClusterRequest{KMSKeyID: "test"},
			requireError: true,
		},
		{
			testName: "valid request",
			request: &model.ProvisionClusterRequest{
				VPCID:       "vpc-1234",
				Environment: "prod",
				StateStore:  "state",
				KMSKeyID:    "arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab",
			},
			requireError: false,
		},
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
