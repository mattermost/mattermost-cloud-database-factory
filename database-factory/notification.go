package dbfactory

import (
	"bytes"
	"encoding/json"
	"net/http"
	"os"
	"strconv"

	"github.com/mattermost/mattermost-cloud-database-factory/model"
	mmmodel "github.com/mattermost/mattermost-server/v5/model"
	"github.com/pkg/errors"
)

func send(webhookURL string, payload mmmodel.CommandResponse) error {
	marshalContent, _ := json.Marshal(payload)
	var jsonStr = []byte(marshalContent)
	req, err := http.NewRequest("POST", webhookURL, bytes.NewBuffer(jsonStr))
	req.Header.Set("X-Custom-Header", "aws-sns")
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	return nil
}

func sendMattermostNotification(cluster *model.Cluster, message string) error {
	attachment := &mmmodel.SlackAttachment{
		Color: "#006400",
		Fields: []*mmmodel.SlackAttachmentField{
			{Title: message, Short: false},
			{Title: "VPCID", Value: cluster.VPCID, Short: true},
			{Title: "Environment", Value: cluster.Environment, Short: true},
			{Title: "StateStore", Value: cluster.StateStore, Short: true},
			{Title: "Apply", Value: strconv.FormatBool(cluster.Apply), Short: true},
			{Title: "InstanceType", Value: cluster.InstanceType, Short: true},
			{Title: "BackupRetentionPeriod", Value: cluster.BackupRetentionPeriod, Short: true},
			{Title: "ClusterID", Value: cluster.ClusterID, Short: true},
			{Title: "DBEngine", Value: cluster.DBEngine, Short: true},
			{Title: "Replicas", Value: cluster.Replicas, Short: true},
		},
	}

	payload := mmmodel.CommandResponse{
		Username:    "Database Factory",
		IconURL:     "https://img.favpng.com/13/4/25/factory-logo-industry-computer-icons-png-favpng-BTgC49vrFrF2SmJZZywXwfL2s.jpg",
		Attachments: []*mmmodel.SlackAttachment{attachment},
	}
	err := send(os.Getenv("MattermostNotificationsHook"), payload)
	if err != nil {
		return errors.Wrap(err, "failed tο send Mattermost request payload")
	}
	return nil
}

func sendMattermostErrorNotification(cluster *model.Cluster, errorMessage error, message string) error {
	attachment := &mmmodel.SlackAttachment{
		Color: "#FF0000",
		Fields: []*mmmodel.SlackAttachmentField{
			{Title: message, Short: false},
			{Title: "Error Message", Value: errorMessage.Error(), Short: false},
			{Title: "VPCID", Value: cluster.VPCID, Short: true},
			{Title: "Environment", Value: cluster.Environment, Short: true},
			{Title: "StateStore", Value: cluster.StateStore, Short: true},
			{Title: "Apply", Value: strconv.FormatBool(cluster.Apply), Short: true},
			{Title: "InstanceType", Value: cluster.InstanceType, Short: true},
			{Title: "BackupRetentionPeriod", Value: cluster.BackupRetentionPeriod, Short: true},
			{Title: "ClusterID", Value: cluster.ClusterID, Short: true},
			{Title: "DBEngine", Value: cluster.DBEngine, Short: true},
			{Title: "Replicas", Value: cluster.Replicas, Short: true},
		},
	}

	payload := mmmodel.CommandResponse{
		Username:    "Database Factory",
		IconURL:     "https://img.favpng.com/13/4/25/factory-logo-industry-computer-icons-png-favpng-BTgC49vrFrF2SmJZZywXwfL2s.jpg",
		Attachments: []*mmmodel.SlackAttachment{attachment},
	}
	err := send(os.Getenv("MattermostAlertsHook"), payload)
	if err != nil {
		return errors.Wrap(err, "failed tο send Mattermost error payload")
	}
	return nil
}
