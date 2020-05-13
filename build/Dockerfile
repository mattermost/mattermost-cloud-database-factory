# Build the mattermost cloud
ARG DOCKER_BUILD_IMAGE=golang:1.14.1
ARG DOCKER_BASE_IMAGE=alpine:3.11.3

FROM ${DOCKER_BUILD_IMAGE} AS build
WORKDIR /mattermost-cloud-database-factory/
COPY . /mattermost-cloud-database-factory/
RUN apt-get update -yq && apt-get install -yq unzip
RUN make get-terraform
RUN make build


# Final Image
FROM ${DOCKER_BASE_IMAGE}
LABEL name="Mattermost Cloud Database Factory" \
  maintainer="cloud-team@mattermost.com" \
  vendor="Mattermost" \
  distribution-scope="public" \
  architecture="x86_64" \
  url="https://mattermost.com" \
  io.k8s.description="Mattermost Cloud Database Factory creates and configures RDS Aurora Clusters" \
  io.k8s.display-name="Mattermost Cloud Database Factory"

ENV CLOUD=/mattermost-cloud-database-factory/dbfactory \
    USER_UID=10001 \
    USER_NAME=cloud

RUN  apk update && apk add libc6-compat && apk add ca-certificates
COPY --from=build /mattermost-cloud-database-factory/build/terraform /usr/local/bin/
COPY --from=build /mattermost-cloud-database-factory/build/_output/bin/dbfactory /mattermost-cloud-database-factory/dbfactory
COPY --from=build /mattermost-cloud-database-factory/build/bin /usr/local/bin
COPY --from=build /mattermost-cloud-database-factory/terraform /mattermost-cloud-database-factory/terraform

RUN  /usr/local/bin/user_setup
WORKDIR /mattermost-cloud-database-factory/

ENTRYPOINT ["/usr/local/bin/entrypoint"]

USER ${USER_UID}
