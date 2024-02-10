#! /usr/bin/env bash

set -o errexit
set -o nounset


source ./env.sh

docker build \
    --tag "$IMAGE_NAME" \
    .
