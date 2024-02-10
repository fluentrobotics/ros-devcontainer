#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


# Use the current git branch, but substitute slashes with hyphens since slashes
# are not allowed in docker tags.
GIT_LABEL="$(git branch --show-current | tr / -)"

# Use the git SHA if we're in detached HEAD mode.
if [[ -z "$GIT_LABEL" ]]; then
    GIT_LABEL="$(git rev-parse --short HEAD)"
fi


export IMAGE_NAME="fluentrobotics/ros:${GIT_LABEL}"
export CONTAINER_NAME="ros-${GIT_LABEL}"
