#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


VALID_TAGS="$(basename --suffix=.Dockerfile ./*.Dockerfile | tr '\n' ' ')"
function usage_error() {
    echo "Usage: ${0} <TAG>"
    echo "<TAG> is one of:" "${VALID_TAGS[@]}"
    exit 1
}

if [[ $# != 1 ]]; then
    usage_error
fi

IMAGE_TAG=$(basename --suffix=.Dockerfile "$1")

# Check whether the user input (1) is a nonempty string and (2) matches one of
# the valid tags.
if ! [[ -n "${IMAGE_TAG}" && " ${VALID_TAGS[*]} " =~ [[:space:]]${IMAGE_TAG}[[:space:]] ]]; then
    echo "Invalid tag: '$1'"
    usage_error
fi

IMAGE_NAME="fluentrobotics/ros:${IMAGE_TAG}"


docker build \
    --tag "$IMAGE_NAME" \
    --file "${IMAGE_TAG}.Dockerfile" \
    .


for rcFile in "$HOME/.bashrc" "$HOME/.zshrc"; do
    # This environment variable is used in devcontainer.json and set here since
    # we can't run shell commands in that file.
    if ! grep -q "^export ROS_DEVCONTAINER_UID=" "$rcFile"; then
        echo "export ROS_DEVCONTAINER_UID=$(id -u):$(id -g)" >> "$rcFile"
        echo "Added \"export ROS_DEVCONTAINER_UID=$(id -u):$(id -g)\" to $rcFile for vscode devcontainers"
    fi
done
