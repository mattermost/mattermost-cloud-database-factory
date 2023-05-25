# Build the mattermost cloud
ARG DOCKER_BUILD_IMAGE=golang:1.19
ARG DOCKER_BASE_IMAGE=alpine:3.17

FROM ${DOCKER_BUILD_IMAGE} AS build
WORKDIR /mattermost-cloud-database-factory/
COPY . /mattermost-cloud-database-factory/
RUN apt-get update -yq && apt-get install -yq unzip
RUN CGO_ENABLED=0 go build -gcflags all=-trimpath=. -asmflags all=-trimpath=. -a -installsuffix cgo -o build/_output/bin/dbfactory  ./cmd/dbfactory


# Final Image
FROM ${DOCKER_BASE_IMAGE}
LABEL name="Mattermost Cloud Database Factory" \
  maintainer="cloud-team@mattermost.com" \
  vendor="Mattermost" \
  distribution-scope="public" \
  url="https://mattermost.com" \
  io.k8s.description="Mattermost Cloud Database Factory provisions and configures RDS Aurora Clusters" \
  io.k8s.display-name="Mattermost Cloud Database Factory"

ENV CLOUD=/mattermost-cloud-database-factory/dbfactory \
    USER_UID=10001 \
    USER_NAME=cloud

RUN  apk update  \
     && apk add --no-cache \
            libc6-compat \
            ca-certificates \
            python3 \
            py3-pip \
     && pip3 install --upgrade pip \
     && pip3 install --no-cache-dir awscli \
     && apk add --no-cache --update-cache terraform \
     && rm -rf /var/cache/apk/*

COPY --from=build /mattermost-cloud-database-factory/build/_output/bin/dbfactory /mattermost-cloud-database-factory/dbfactory
COPY --from=build /mattermost-cloud-database-factory/build/bin /usr/local/bin
COPY --from=build /mattermost-cloud-database-factory/terraform /mattermost-cloud-database-factory/terraform

RUN  /usr/local/bin/user_setup
WORKDIR /mattermost-cloud-database-factory/

ENTRYPOINT ["/usr/local/bin/entrypoint"]

USER ${USER_UID}
