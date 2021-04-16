package main

import (
	"errors"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/rds"
	"github.com/stretchr/testify/assert"
)

func TestSearchCommand(t *testing.T) {

	samples := []struct {
		description            string
		describeDBClusters     func(in *rds.DescribeDBClustersInput) (*rds.DescribeDBClustersOutput, error)
		describeDBSubnetGroups func(in *rds.DescribeDBSubnetGroupsInput) (*rds.DescribeDBSubnetGroupsOutput, error)
		err                    error
	}{
		{
			description: "DescribeDBCluster error",
			describeDBClusters: func(in *rds.DescribeDBClustersInput) (*rds.DescribeDBClustersOutput, error) {
				return nil, errors.New("error describe cluster")
			},
			err: errors.New("error describe cluster"),
		},
		{
			description: "DescribeDBCluster empty",
			describeDBClusters: func(in *rds.DescribeDBClustersInput) (*rds.DescribeDBClustersOutput, error) {
				return &rds.DescribeDBClustersOutput{}, nil
			},
			err: nil,
		},
		{
			description: "Fail DescribeDBSubnetGroups",
			describeDBClusters: func(in *rds.DescribeDBClustersInput) (*rds.DescribeDBClustersOutput, error) {
				return &rds.DescribeDBClustersOutput{
					DBClusters: []*rds.DBCluster{
						{
							DBSubnetGroup:         aws.String("subnet-group"),
							DBClusterIdentifier:   aws.String("test-identifier"),
							Engine:                aws.String("postgres"),
							EngineVersion:         aws.String("11.9"),
							BackupRetentionPeriod: aws.Int64(15),
						},
					},
				}, nil
			},
			describeDBSubnetGroups: func(in *rds.DescribeDBSubnetGroupsInput) (*rds.DescribeDBSubnetGroupsOutput, error) {
				return nil, errors.New("errors describe subnet group")
			},
			err: errors.New("errors describe subnet group"),
		},
		{
			description: "Success",
			describeDBClusters: func(in *rds.DescribeDBClustersInput) (*rds.DescribeDBClustersOutput, error) {
				return &rds.DescribeDBClustersOutput{
					DBClusters: []*rds.DBCluster{
						{
							DBSubnetGroup:         aws.String("subnet-group"),
							DBClusterIdentifier:   aws.String("test-identifier"),
							Engine:                aws.String("postgres"),
							EngineVersion:         aws.String("11.9"),
							BackupRetentionPeriod: aws.Int64(15),
						},
					},
				}, nil
			},
			describeDBSubnetGroups: func(in *rds.DescribeDBSubnetGroupsInput) (*rds.DescribeDBSubnetGroupsOutput, error) {
				return &rds.DescribeDBSubnetGroupsOutput{
					DBSubnetGroups: []*rds.DBSubnetGroup{
						{
							VpcId: aws.String("vpc-1234"),
						},
					},
				}, nil
			},
			err: nil,
		},
	}
	for _, s := range samples {
		t.Run(s.description, func(t *testing.T) {
			mockedRDS := mockRDS{}
			mockedRDS.describeDBClusters = s.describeDBClusters
			mockedRDS.describeDBSubnetGroups = s.describeDBSubnetGroups
			cmd := newSearchCommand(&mockedRDS)
			err := cmd.Execute()
			if s.err == nil {
				assert.NoError(t, err)
				return
			}
			assert.Error(t, s.err, err)
		})
	}
}
