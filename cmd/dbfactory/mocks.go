package main

import (
	"github.com/aws/aws-sdk-go/service/rds"
	"github.com/aws/aws-sdk-go/service/rds/rdsiface"
)

type mockRDS struct {
	rdsiface.RDSAPI

	describeDBClusters     func(in *rds.DescribeDBClustersInput) (*rds.DescribeDBClustersOutput, error)
	describeDBSubnetGroups func(in *rds.DescribeDBSubnetGroupsInput) (*rds.DescribeDBSubnetGroupsOutput, error)
}

func (m *mockRDS) DescribeDBClusters(in *rds.DescribeDBClustersInput) (*rds.DescribeDBClustersOutput, error) {
	return m.describeDBClusters(in)
}

func (m *mockRDS) DescribeDBSubnetGroups(in *rds.DescribeDBSubnetGroupsInput) (*rds.DescribeDBSubnetGroupsOutput, error) {
	return m.describeDBSubnetGroups(in)
}
