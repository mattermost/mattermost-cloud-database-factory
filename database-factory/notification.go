package dbfactory

import (
	"bytes"
	"encoding/json"
	"net/http"
	"os"
	"strconv"

	"github.com/mattermost/mattermost-cloud-database-factory/model"
	"github.com/pkg/errors"
)

// MMField is used for Mattermost attachement creation
type MMField struct {
	Title string `json:"title"`
	Value string `json:"value"`
	Short bool   `json:"short"`
}

// MMAttachment is used to create a Mattermost attachment
type MMAttachment struct {
	Fallback   *string    `json:"fallback"`
	Color      string     `json:"color"`
	PreText    *string    `json:"pretext"`
	AuthorName *string    `json:"author_name"`
	AuthorLink *string    `json:"author_link"`
	AuthorIcon *string    `json:"author_icon"`
	Title      *string    `json:"title"`
	TitleLink  *string    `json:"title_link"`
	Text       *string    `json:"text"`
	ImageURL   *string    `json:"image_url"`
	Fields     []*MMField `json:"fields"`
}

// MMSlashResponse is used to create the payload for the Mattermost notification
type MMSlashResponse struct {
	ResponseType string         `json:"response_type,omitempty"`
	Username     string         `json:"username,omitempty"`
	IconURL      string         `json:"icon_url,omitempty"`
	Channel      string         `json:"channel,omitempty"`
	Text         string         `json:"text,omitempty"`
	GotoLocation string         `json:"goto_location,omitempty"`
	Attachments  []MMAttachment `json:"attachments,omitempty"`
}

// AddField adds a field to a Mattermost attachment
func (attachment *MMAttachment) AddField(field MMField) *MMAttachment {
	attachment.Fields = append(attachment.Fields, &field)
	return attachment
}

func send(webhookURL string, payload MMSlashResponse) error {
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
	attachment := []MMAttachment{}
	attach := MMAttachment{
		Color: "#006400",
	}

	attach = *attach.AddField(MMField{Title: message, Short: false}).
		AddField(MMField{Title: "VPCID", Value: cluster.VPCID, Short: true}).
		AddField(MMField{Title: "Environment", Value: cluster.Environment, Short: true}).
		AddField(MMField{Title: "StateStore", Value: cluster.StateStore, Short: true}).
		AddField(MMField{Title: "Apply", Value: strconv.FormatBool(cluster.Apply), Short: true}).
		AddField(MMField{Title: "InstanceType", Value: cluster.InstanceType, Short: true}).
		AddField(MMField{Title: "BackupRetentionPeriod", Value: cluster.BackupRetentionPeriod, Short: true}).
		AddField(MMField{Title: "ClusterID", Value: cluster.ClusterID, Short: true})

	attachment = append(attachment, attach)

	payload := MMSlashResponse{
		Username:    "Database Factory",
		IconURL:     "https://img.favpng.com/13/4/25/factory-logo-industry-computer-icons-png-favpng-BTgC49vrFrF2SmJZZywXwfL2s.jpg",
		Attachments: attachment,
	}
	err := send(os.Getenv("MattermostNotificationsHook"), payload)
	if err != nil {
		return errors.Wrap(err, "failed tο send Mattermost request payload")
	}
	return nil
}

func sendMattermostErrorNotification(cluster *model.Cluster, errorMessage error, message string) error {
	attachment := []MMAttachment{}
	attach := MMAttachment{
		Color: "#FF0000",
	}

	attach = *attach.AddField(MMField{Title: message, Short: false}).
		AddField(MMField{Title: "Error Message", Value: errorMessage.Error(), Short: false}).
		AddField(MMField{Title: "VPCID", Value: cluster.VPCID, Short: true}).
		AddField(MMField{Title: "Environment", Value: cluster.Environment, Short: true}).
		AddField(MMField{Title: "StateStore", Value: cluster.StateStore, Short: true}).
		AddField(MMField{Title: "Apply", Value: strconv.FormatBool(cluster.Apply), Short: true}).
		AddField(MMField{Title: "InstanceType", Value: cluster.InstanceType, Short: true}).
		AddField(MMField{Title: "BackupRetentionPeriod", Value: cluster.BackupRetentionPeriod, Short: true}).
		AddField(MMField{Title: "ClusterID", Value: cluster.ClusterID, Short: true})

	attachment = append(attachment, attach)

	payload := MMSlashResponse{
		Username:    "Database Factory",
		IconURL:     "https://img.favpng.com/13/4/25/factory-logo-industry-computer-icons-png-favpng-BTgC49vrFrF2SmJZZywXwfL2s.jpg",
		Attachments: attachment,
	}
	err := send(os.Getenv("MattermostAlertsHook"), payload)
	if err != nil {
		return errors.Wrap(err, "failed tο send Mattermost error payload")
	}
	return nil
}
