################################################################################
##                             VERSION PARAMS                                 ##
################################################################################

## Docker Build Versions
DOCKER_BUILD_IMAGE = golang:1.17
DOCKER_BASE_IMAGE = alpine:3.14

## Tool Versions
TERRAFORM_VERSION=1.1.8

################################################################################

GO ?= $(shell command -v go 2> /dev/null)
MATTERMOST_CLOUD_DATABASE_FACTORY_IMAGE ?= mattermost/mattermost-cloud-database-factory:test
MACHINE = $(shell uname -m)
GOFLAGS ?= $(GOFLAGS:)
BUILD_TIME := $(shell date -u +%Y%m%d.%H%M%S)
BUILD_HASH := $(shell git rev-parse HEAD)

################################################################################

LOGRUS_URL := github.com/sirupsen/logrus

LOGRUS_VERSION := $(shell find go.mod -type f -exec cat {} + | grep ${LOGRUS_URL} | awk '{print $$NF}')

LOGRUS_PATH := $(GOPATH)/pkg/mod/${LOGRUS_URL}\@${LOGRUS_VERSION}

export GO111MODULE=on

## Checks the code style, tests, builds and bundles.
all: check-style dist

## Runs govet and gofmt against all packages.
.PHONY: check-style
check-style: govet lint
	@echo Checking for style guide compliance

## Runs lint against all packages.
.PHONY: lint
lint:
	@echo Running lint
	env GO111MODULE=off $(GO) get -u golang.org/x/lint/golint
	golint -set_exit_status ./...
	@echo lint success

## Runs govet against all packages.
.PHONY: vet
govet:
	@echo Running govet
	$(GO) vet ./...
	@echo Govet success

## Builds and thats all :)
.PHONY: dist
dist:	build

.PHONY: build
build: ## Build the mattermost-cloud-database-factory
	@echo Building Mattermost-Cloud-Database-Factory
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 $(GO) build -gcflags all=-trimpath=$(PWD) -asmflags all=-trimpath=$(PWD) -a -installsuffix cgo -o build/_output/bin/dbfactory  ./cmd/dbfactory

build-image:  ## Build the docker image for mattermost-cloud-database-factory
	@echo Building Mattermost-cloud-database-factory Docker Image
	docker build \
	--build-arg DOCKER_BUILD_IMAGE=$(DOCKER_BUILD_IMAGE) \
	--build-arg DOCKER_BASE_IMAGE=$(DOCKER_BASE_IMAGE) \
	. -f build/Dockerfile -t $(MATTERMOST_CLOUD_DATABASE_FACTORY_IMAGE) \
	--no-cache

get-terraform: ## Download terraform only if it's not available. Used in the docker build
	@if [ ! -f build/terraform ]; then \
		curl -Lo build/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && cd build && unzip terraform.zip &&\
		chmod +x terraform && rm terraform.zip;\
	fi

.PHONY: install
install: build
	go install ./...

# Generate mocks from the interfaces.
.PHONY: mocks
mocks:
	@if [ ! -f $(GOPATH)/pkg/mod ]; then \
		$(GO) mod download;\
	fi

	# Mockgen cannot generate mocks for logrus when reading it from modules.
	GO111MODULE=off $(GO) get github.com/sirupsen/logrus
	$(GOPATH)/bin/mockgen -source $(GOPATH)/src/github.com/sirupsen/logrus/logrus.go -package mocks -destination ./internal/mocks/logger/logrus.go

# Installs necessary tools for testing
.PHONY: setup-test
setup-test:
	@echo Installing cover
	go get golang.org/x/tools/cmd/cover

# Running the tests
.PHONY: test
test:
	@echo Running tests
	go test ./... -v -covermode=count -coverprofile=coverage.out

# Cut a release
.PHONY: release
release:
	@echo Cut a release
	sh ./scripts/release.sh

# Notify a release publish
.PHONY: notify
notify:
	@echo Notify a release publish
	sh ./scripts/notify.sh