package api_test

import (
	"bytes"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gorilla/mux"
	"github.com/mattermost/mattermost-cloud-database-factory/api"
	"github.com/mattermost/mattermost-cloud-database-factory/internal/testlib"
	"github.com/mattermost/mattermost-cloud-database-factory/model"
	"github.com/stretchr/testify/require"
)

func TestProvisionCluster(t *testing.T) {
	logger := testlib.MakeLogger(t)

	router := mux.NewRouter()
	api.Register(router, &api.Context{
		Logger: logger,
	})
	ts := httptest.NewServer(router)
	defer ts.Close()

	client := model.NewClient(ts.URL)

	t.Run("invalid payload", func(t *testing.T) {
		resp, err := http.Post(fmt.Sprintf("%s/api/provision", ts.URL), "application/json", bytes.NewReader([]byte("invalid")))
		require.NoError(t, err)
		require.Equal(t, http.StatusBadRequest, resp.StatusCode)
	})

	t.Run("empty payload", func(t *testing.T) {
		resp, err := http.Post(fmt.Sprintf("%s/api/provision", ts.URL), "application/json", bytes.NewReader([]byte("")))
		require.NoError(t, err)
		require.Equal(t, http.StatusBadRequest, resp.StatusCode)
	})

	t.Run("empty vpc id", func(t *testing.T) {
		_, err := client.ProvisionCluster(&model.ProvisionClusterRequest{
			VPCID:                 "",
			ClusterID:             "12345678",
			Environment:           "test",
			StateStore:            "testbucket",
			Apply:                 false,
			BackupRetentionPeriod: "15",
			DBEngine:              "postgres",
			Replicas:              "3",
			DBProxy:               true,
		})
		require.EqualError(t, err, "failed with status code 400")
	})

	t.Run("empty environment", func(t *testing.T) {
		_, err := client.ProvisionCluster(&model.ProvisionClusterRequest{
			VPCID:                 "vpc-12345678",
			ClusterID:             "12345678",
			Environment:           "",
			StateStore:            "testbucket",
			Apply:                 false,
			BackupRetentionPeriod: "15",
			DBEngine:              "postgres",
			Replicas:              "3",
			DBProxy:               true,
		})
		require.EqualError(t, err, "failed with status code 400")
	})

	t.Run("empty state store", func(t *testing.T) {
		_, err := client.ProvisionCluster(&model.ProvisionClusterRequest{
			VPCID:                    "vpc-12345678",
			ClusterID:                "12345678",
			Environment:              "test",
			StateStore:               "",
			Apply:                    false,
			BackupRetentionPeriod:    "15",
			DBEngine:                 "postgres",
			Replicas:                 "3",
			DBProxy:                  true,
			EnableDevopsGuru:         true,
			AllowMajorVersionUpgrade: false,
		})
		require.EqualError(t, err, "failed with status code 400")
	})

	t.Run("valid", func(t *testing.T) {
		cluster, err := client.ProvisionCluster(&model.ProvisionClusterRequest{
			VPCID:                    "vpc-12345678",
			ClusterID:                "12345678",
			Environment:              "test",
			StateStore:               "testbucket",
			Apply:                    false,
			InstanceType:             "test-type",
			BackupRetentionPeriod:    "16",
			DBEngine:                 "mysql",
			Replicas:                 "2",
			DBProxy:                  false,
			EnableDevopsGuru:         false,
			AllowMajorVersionUpgrade: false,
		})
		require.NoError(t, err)
		require.Equal(t, "vpc-12345678", cluster.VPCID)
		require.Equal(t, "12345678", cluster.ClusterID)
		require.Equal(t, "test", cluster.Environment)
		require.Equal(t, "testbucket", cluster.StateStore)
		require.Equal(t, false, cluster.Apply)
		require.Equal(t, "test-type", cluster.InstanceType)
		require.Equal(t, "16", cluster.BackupRetentionPeriod)
		require.Equal(t, "mysql", cluster.DBEngine)
		require.Equal(t, "2", cluster.Replicas)
		require.Equal(t, false, cluster.DBProxy)
		require.Equal(t, false, cluster.EnableDevopsGuru)
		require.Equal(t, false, cluster.AllowMajorVersionUpgrade)
	})
}
