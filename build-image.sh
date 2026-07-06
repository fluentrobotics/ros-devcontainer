#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ -n "${NO_COLOR:-}" ]]; then
    YELLOW=""
    MAGENTA=""
    RESET=""
else
    YELLOW=$'\033[33m'
    MAGENTA=$'\033[35m'
    RESET=$'\033[0m'
fi


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

IMAGE_NAME="$(id --user --name)/ros:${IMAGE_TAG}"
# NOTE: This is also used as the container hostname, so we expect a normal
# lowercase alpha username here. We'll skip sanitization for script readability,
# but if you're an insane person who puts underscores in your username, it might
# break the container.
CONTAINER_NAME="$(id --user --name)-ros-${IMAGE_TAG}"


docker build \
    --tag "$IMAGE_NAME" \
    --file "${IMAGE_TAG}.Dockerfile" \
    .

# Check whether the container is running already.
# https://stackoverflow.com/a/43723174
if docker container inspect -f '{{.State.Running}}' "$CONTAINER_NAME" &> /dev/null; then
    printf '\n%sWarning: An older build of this image is currently running. The existing container must be shut down before using the new build.%s' "$YELLOW" "$RESET"
    printf '\n\n\t%sdocker stop -t 0 %s%s\n\n' "$MAGENTA" "$CONTAINER_NAME" "$RESET"
fi
