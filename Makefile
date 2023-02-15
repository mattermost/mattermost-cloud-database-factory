################################################################################
##                             VERSION PARAMS                                 ##
################################################################################

## Docker Build Versions
DOCKER_BUILD_IMAGE = golang:1.19
DOCKER_BASE_IMAGE = alpine:3.17

## Tool Versions
TERRAFORM_VERSION=1.3.7

################################################################################

GO ?= $(shell command -v go 2> /dev/null)
MATTERMOST_CLOUD_DATABASE_FACTORY_IMAGE_REPO ?=mattermost/mattermost-cloud-database-factory
MATTERMOST_CLOUD_DATABASE_FACTORY_IMAGE ?= mattermost/mattermost-cloud-database-factory:test
MACHINE = $(shell uname -m)
GOFLAGS ?= $(GOFLAGS:)
BUILD_TIME := $(shell date -u +%Y%m%d.%H%M%S)
BUILD_HASH := $(shell git rev-parse HEAD)
PACKAGES=$(shell go list ./... | grep -v internal/mocks)

################################################################################

TOOLS_BIN_DIR := $(abspath bin)
GO_INSTALL = ./scripts/go_install.sh

MOCKGEN_VER := v1.4.3
MOCKGEN_BIN := mockgen
MOCKGEN := $(TOOLS_BIN_DIR)/$(MOCKGEN_BIN)-$(MOCKGEN_VER)

OUTDATED_VER := master
OUTDATED_BIN := go-mod-outdated
OUTDATED_GEN := $(TOOLS_BIN_DIR)/$(OUTDATED_BIN)

GOLANGCILINT_VER := v1.50.1
GOLANGCILINT_BIN := golangci-lint
GOLANGCILINT := $(TOOLS_BIN_DIR)/$(GOLANGCILINT_BIN)

TRIVY_SEVERITY := CRITICAL
TRIVY_EXIT_CODE := 1
TRIVY_VULN_TYPE := os,library

export GO111MODULE=on

## Checks the code style, tests, builds and bundles.
all: check-style dist

## Runs govet and gofmt against all packages.
.PHONY: check-style
check-style: govet lint tflint goformat
	@echo Checking for style guide compliance

## Runs lint against all packages.
.PHONY: lint
lint: $(GOLANGCILINT)
	@echo Running golangci-lint
	$(GOLANGCILINT) run

## Runs lint against all packages for changes only
.PHONY: lint-changes
lint-changes: $(GOLANGCILINT)
	@echo Running golangci-lint over changes only
	$(GOLANGCILINT) run -n

.PHONY: tflint
tflint: setup-tflint plugin-tflint terraform-lint

## setup: install tflint
.PHONY: setup-tflint
setup-tflint:
	curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

.PHONY: plugin-tflint
## installing aws plugin for tflint
plugin-tflint:
	tflint --init --config .tflint.hcl

.PHONY: terraform-lint
terraform-lint:
	@echo "Linting all modules"
	bash -c "./scripts/terraform_lint.sh"

## Checks if files are formatted with go fmt.
.PHONY: goformat
goformat:
	@echo Checking if code is formatted
	@for package in $(PACKAGES); do \
		echo "Checking "$$package; \
		files=$$(go list -f '{{range .GoFiles}}{{$$.Dir}}/{{.}} {{end}}' $$package); \
		if [ "$$files" ]; then \
			gofmt_output=$$(gofmt -d -s $$files 2>&1); \
			if [ "$$gofmt_output" ]; then \
				echo "$$gofmt_output"; \
				echo "gofmt failed"; \
				echo "To fix it, run:"; \
				echo "go fmt [FAILED_PACKAGE]"; \
				exit 1; \
			fi; \
		fi; \
	done
	@echo "gofmt success"; \

## Runs govet against all packages.
.PHONY: vet
govet:
	@echo Running govet
	$(GO) vet ./...
	@echo Govet success

## Builds and thats all :)
.PHONY: dist
dist:	build

.PHONY: binaries
binaries:
	@echo Building binaries of Mattermost-Cloud-Database-Factory
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 $(GO) build -gcflags all=-trimpath=$(PWD) -asmflags all=-trimpath=$(PWD) -a -installsuffix cgo -o build/_output/bin/dbfactory-linux-amd64  ./cmd/$(APP)
	GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 $(GO) build -gcflags all=-trimpath=$(PWD) -asmflags all=-trimpath=$(PWD) -a -installsuffix cgo -o build/_output/bin/dbfactory-darwin-amd64  ./cmd/$(APP)
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 $(GO) build -gcflags all=-trimpath=$(PWD) -asmflags all=-trimpath=$(PWD) -a -installsuffix cgo -o build/_output/bin/dbfactory-linux-arm64 ./cmd/$(APP)
	GOOS=darwin GOARCH=arm64 CGO_ENABLED=0 $(GO) build -gcflags all=-trimpath=$(PWD) -asmflags all=-trimpath=$(PWD) -a -installsuffix cgo -o build/_output/bin/dbfactory-darwin-arm64  ./cmd/$(APP)

## Checks for vulnerabilities
trivy: build-image
	@echo running trivy
	@trivy image --format table --exit-code $(TRIVY_EXIT_CODE) --ignore-unfixed --vuln-type $(TRIVY_VULN_TYPE) --severity $(TRIVY_SEVERITY) $(MATTERMOST_CLOUD_DATABASE_FACTORY_IMAGE)

.PHONY: build
build: ## Build the mattermost-cloud-database-factory
	@echo Building Mattermost-Cloud-Database-Factory
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 $(GO) build -gcflags all=-trimpath=$(PWD) -asmflags all=-trimpath=$(PWD) -a -installsuffix cgo -o build/_output/bin/dbfactory  ./cmd/dbfactory

.PHONY: build-image
build-image:  ## Build the docker image for mattermost-cloud-database-factory
	@echo Building Mattermost-cloud-database-factory Docker Image
	echo $$DOCKERHUB_TOKEN | docker login --username $$DOCKERHUB_USERNAME --password-stdin && \
	docker buildx build \
    --platform linux/arm64,linux/amd64 \
	--build-arg DOCKER_BUILD_IMAGE=$(DOCKER_BUILD_IMAGE) \
	--build-arg DOCKER_BASE_IMAGE=$(DOCKER_BASE_IMAGE) \
	. -f build/Dockerfile -t $(MATTERMOST_CLOUD_DATABASE_FACTORY_IMAGE) \
	--no-cache \
	--push

.PHONY: build-image-with-tag
build-image-with-tag:  ## Build the docker image for mattermost-cloud-database-factory
	@echo Building Mattermost-cloud-database-factory Docker Image
	echo $$DOCKERHUB_TOKEN | docker login --username $$DOCKERHUB_USERNAME --password-stdin && \
	docker buildx build \
    --platform linux/arm64,linux/amd64 \
	--build-arg DOCKER_BUILD_IMAGE=$(DOCKER_BUILD_IMAGE) \
	--build-arg DOCKER_BASE_IMAGE=$(DOCKER_BASE_IMAGE) \
	. -f build/Dockerfile -t $(MATTERMOST_CLOUD_DATABASE_FACTORY_IMAGE_REPO):${TAG} \
	--no-cache \
	--push

.PHONY: push-image-pr
push-image-pr:
	@echo Push Image PR
	./scripts/push-image-pr.sh

.PHONY: push-image
push-image:
	@echo Push Image
	./scripts/push-image.sh

.PHONY: get-terraform
get-terraform: ## Download terraform only if it's not available. Used in the docker build
	@if [ ! -f build/terraform ]; then \
		curl -Lo build/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && cd build && unzip terraform.zip &&\
		chmod +x terraform && rm terraform.zip;\
	fi

.PHONY: install
install: build
	go install ./...

.PHONY: check-modules
check-modules: $(OUTDATED_GEN) ## Check outdated modules
	@echo Checking outdated modules
	$(GO) list -u -m -json all | $(OUTDATED_GEN) -update -direct

.PHONY: update-modules
update-modules: $(OUTDATED_GEN) ## Check outdated modules
	@echo Update modules
	$(GO) get -u ./...
	$(GO) mod tidy

# Generate mocks from the interfaces.
.PHONY: mocks
mocks: $(MOCKGEN)
	go generate ./internal/mocks/...

.PHONY: verify-mocks
verify-mocks:  $(MOCKGEN) mocks
	@if !(git diff --quiet HEAD); then \
		echo "generated files are out of date, run make mocks"; exit 1; \
	fi

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

# Install dependencies for release notes
.PHONY: deps
deps:
	sudo apt update && sudo apt install hub git && GO111MODULE=on go install k8s.io/release/cmd/release-notes@latest

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

## --------------------------------------
## Tooling Binaries
## --------------------------------------

$(MOCKGEN): ## Build mockgen.
	GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) github.com/golang/mock/mockgen $(MOCKGEN_BIN) $(MOCKGEN_VER)

$(OUTDATED_GEN): ## Build go-mod-outdated.
	GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) github.com/psampaz/go-mod-outdated $(OUTDATED_BIN) $(OUTDATED_VER)

$(GOLANGCILINT): ## Build golangci-lint
	GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) github.com/golangci/golangci-lint/cmd/golangci-lint $(GOLANGCILINT_BIN) $(GOLANGCILINT_VER)
