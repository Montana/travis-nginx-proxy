#!/bin/bash

set -e

cleanup() {
  echo "Cleaning up..."
  cd /
  rm -rf /src
  apk del .acmesh-deps
}

# Enforce cleanup is called on script exit or error
trap cleanup EXIT

echo "Installing git..."
apk --no-cache add --virtual .acmesh-deps git

echo "Cloning acme.sh from official repository..."
mkdir -p /src && cd /src
git clone https://github.com/acmesh-official/acme.sh.git
cd acme.sh

if [ "$ACMESH_VERSION" != "master" ]; then
  echo "Checking out acme.sh version: $ACMESH_VERSION"
  git -c advice.detachedHead=false checkout "$ACMESH_VERSION"
fi

echo "Installing acme.sh..."
./acme.sh --install \
  --nocron \
  --auto-upgrade 0 \
  --home /app \
  --config-home /etc/acme.sh/default

echo "Installation complete."
