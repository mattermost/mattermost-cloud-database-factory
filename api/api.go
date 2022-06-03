package api

import (
	"net/http"

	"github.com/gorilla/mux"
	dbfactory "github.com/mattermost/mattermost-cloud-database-factory/database-factory"
	"github.com/mattermost/mattermost-cloud-database-factory/model"
)

// Register registers the API endpoints on the given router.
func Register(rootRouter *mux.Router, context *Context) {
	apiRouter := rootRouter.PathPrefix("/api").Subrouter()

	initCluster(apiRouter, context)
}

// initCluster registers RDS cluster endpoints on the given router.
func initCluster(apiRouter *mux.Router, context *Context) {
	addContext := func(handler contextHandlerFunc) *contextHandler {
		return newContextHandler(context, handler)
	}

	clustersRouter := apiRouter.PathPrefix("/provision").Subrouter()
	clustersRouter.Handle("", addContext(handleProvisionDBCluster)).Methods("POST")
}

// handleProvisionDBCluster responds to POST /api/provision, beginning the process of creating a new RDS Aurora cluster.
// sample body:
// {
//     "vpcID": "vpc-12345678",
//     "environment": "dev",
//     "stateStore": "terraform-database-factory-state-bucket-dev",
//     "apply": true,
//     "instanceType": "db.r5.large",
//     "clusterID": "12345678",
//     "backupRetentionPeriod": "15",
//     "dbEngine: postgres",
//     "maxConnections": "150000"
//     "replicas": "3"
//     "dbProxy": true
// }
func handleProvisionDBCluster(c *Context, w http.ResponseWriter, r *http.Request) {
	provisionClusterRequest, err := model.NewProvisionClusterRequestFromReader(r.Body)
	if err != nil {
		c.Logger.WithError(err).Error("failed to decode request")
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	cluster := model.Cluster{
		VPCID:                 provisionClusterRequest.VPCID,
		ClusterID:             provisionClusterRequest.ClusterID,
		Environment:           provisionClusterRequest.Environment,
		StateStore:            provisionClusterRequest.StateStore,
		Apply:                 provisionClusterRequest.Apply,
		InstanceType:          provisionClusterRequest.InstanceType,
		BackupRetentionPeriod: provisionClusterRequest.BackupRetentionPeriod,
		DBEngine:              provisionClusterRequest.DBEngine,
		MaxConnections:        provisionClusterRequest.MaxConnections,
		Replicas:              provisionClusterRequest.Replicas,
		DBProxy:               provisionClusterRequest.DBProxy,
	}

	go dbfactory.InitProvisionCluster(&cluster)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusAccepted)
	outputJSON(c, w, cluster)
}
