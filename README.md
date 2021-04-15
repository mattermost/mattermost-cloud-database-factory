# Mattermost Cloud Database Factory

This repository houses the open-source components of Mattermost Cloud Database Factory. The database factory is a microservice with the purpose of deploying RDS Aurora Clusters via a API service.

For the configuration Terraform templates and modules are being used, preconfigured to meet Mattermost Cloud standards, but can be easily adapted to deploy RDS Aurora Clusters in any possible configuration. The database factory deploys and updates the RDS clusters.

## Developing

### Environment Setup

1. Install [Go](https://golang.org/doc/install)
2. Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) version v0.13.5
3. Specify the region in your AWS config, e.g. `~/.aws/config`:
```
[profile mm-cloud]
region = us-east-1
```
4. Generate an AWS Access and Secret key pair, then export them in your bash profile:
  ```
  export AWS_ACCESS_KEY_ID=YOURACCESSKEYID
  export AWS_SECRET_ACCESS_KEY=YOURSECRETACCESSKEY
  export AWS_PROFILE=mm-cloud
  ```
5. Create an S3 bucket to store the terraform state
6. Clone this repository into your GOPATH (or anywhere if you have Go Modules enabled)

### Building

Simply run the following:

```
$ go install ./cmd/dbfactory
```

### Running

Run the server with:

```
$ dbfactory server
```
where dbfactory is an alias for /go/bin/dbfactory

### Testing

Run the go tests to test:

```
$ go test ./...
```

### Deploying RDS Aurora Clusters

Deploy a RDS Cluster with the command-line:

```
dbfactory cluster provision --environment <environment> --vpc-id vpc-xxxxxx --state-store=<state_storage_bucket> --instance-type <db_instance_type> --apply
```
or via a API call:

```json
{
    "vpcID": "",
    "environment": "",
    "stateStore": "",
    "apply": true,
    "instanceType": "",
    "clusterID": "",
    "backupRetentionPeriod" : ""
}
```

The clusterID value is important for determining how the database factory will behave. If not clusterID is passed in, a random 8-digit ID is generated. If a clusterID of an existing cluster is specified, Terraform will try to update the existing cluster configuration.

By setting **apply** to *false* or removing **--apply**, a Terraform plan will run, which can be used for Debug and testing purposes.

**Note:** You need to export in your environment variables the aws profile and explicit set the aws region you want to run the change. An example is the following:

```bash
export AWS_PROFILE=mm-cloud-dev
export AWS_REGION=us-east-1
```