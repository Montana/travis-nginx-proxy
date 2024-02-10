FROM nginxproxy/docker-gen:0.11.2 AS docker-gen

FROM alpine:3.19.1

ARG GIT_DESCRIBE="unknown"
ARG ACMESH_VERSION=3.0.7

ENV ACMESH_VERSION=${ACMESH_VERSION} \
    COMPANION_VERSION=${GIT_DESCRIBE} \
    DOCKER_HOST=unix:///var/run/docker.sock \
    PATH=${PATH}:/app

# Install packages required by the image
RUN apk add --no-cache --virtual .bin-deps \
    bash \
    bind-tools \
    coreutils \
    curl \
    jq \
    libidn \
    oath-toolkit-oathtool \
    openssh-client \
    openssl \
    sed \
    socat \
    tar \
    tzdata

COPY --from=docker-gen /usr/local/bin/docker-gen /usr/local/bin/

# Install acme.sh
RUN chmod +rx /install_acme.sh \
    && sync \
    && install_acme.sh \
    && rm -f install_acme.sh
