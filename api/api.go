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

	clustersRouter := apiRouter.PathPrefix("/create").Subrouter()
	clustersRouter.Handle("", addContext(handleCreateDBCluster)).Methods("POST")
}

// handleCreateDBCluster responds to POST /api/create, beginning the process of creating a new RDS Aurora cluster.
// sample body:
// {
//     "vpcID": "vpc-12345678",
//     "environment": "dev",
//     "stateStore": "terraform-database-factory-state-bucket-dev",
//     "apply": true,
//     "instanceType": "db.r5.large",
//     "clusterID": "12345678",
//     "backupRetentionPeriod": "15",
//     "dbEngine: postgresql",
//     "maxConnections": "150000"
//     "replicas": "3"
// }
func handleCreateDBCluster(c *Context, w http.ResponseWriter, r *http.Request) {
	createClusterRequest, err := model.NewCreateClusterRequestFromReader(r.Body)
	if err != nil {
		c.Logger.WithError(err).Error("failed to decode request")
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	cluster := model.Cluster{
		VPCID:                 createClusterRequest.VPCID,
		ClusterID:             createClusterRequest.ClusterID,
		Environment:           createClusterRequest.Environment,
		StateStore:            createClusterRequest.StateStore,
		Apply:                 createClusterRequest.Apply,
		InstanceType:          createClusterRequest.InstanceType,
		BackupRetentionPeriod: createClusterRequest.BackupRetentionPeriod,
		DBEngine:              createClusterRequest.DBEngine,
		MaxConnections:        createClusterRequest.MaxConnections,
		Replicas:              createClusterRequest.Replicas,
	}

	go dbfactory.InitCreateCluster(&cluster)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusAccepted)
	outputJSON(c, w, cluster)
}
