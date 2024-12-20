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
CONTAINER_NAME="ros-${IMAGE_TAG}"


# Check whether the Docker image is missing. `docker inspect` will exit with a
# non-zero code if the image does not exist.
if ! docker inspect "$IMAGE_NAME" &> /dev/null ; then
    # Build the image before proceeding further.
    ./build-image.sh "$IMAGE_TAG"
fi


# Additional things we need to run for GUI applications
# (doc/gui-applications.md)
xhost +local:docker > /dev/null


# Store the arguments to `docker run` in an array so we can add comments
# explaining what the arguments mean. https://stackoverflow.com/a/9522766
# Sync any changes here to runArgs in devcontainer.json
args=(
    # Tell Docker to delete the container immediately after we exit out of it.
    --rm

    --name "$CONTAINER_NAME"

    # These flags are needed for interactive shell sessions.
    --interactive
    --tty
    --env TERM=xterm-256color

    # Setting the network option to "host" allows applications in the Docker
    # container (e.g., ROS) to access the network interfaces of the host system
    # directly. We enable "host" mode because may want to communicate with a ROS
    # node somewhere across the network and it's easier to figure out IP
    # addresses this way.
    --network=host

    # Set the hostname within the Docker container to the name of the Docker
    # image we built. This is useful for quickly determining whether the active
    # terminal is tied to a shell session in this Docker container or a shell
    # session on the host.
    --hostname="$CONTAINER_NAME"

    # Settings for GUI applications (doc/gui-applications.md).
    --ipc=host
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:ro"
    --volume="/dev/dri:/dev/dri:ro"
    --env DISPLAY="$DISPLAY"

    # User spoofing (doc/user-spoofing.md)
    --group-add="sudo"
    --user="$(id -u):$(id -g)"
    --volume="/etc/group:/etc/group:ro"
    --volume="/etc/passwd:/etc/passwd:ro"
    --volume="/etc/shadow:/etc/shadow:ro"
    --volume="$HOME:$HOME"
    --workdir="$HOME"

    # Enable NVIDIA GPUs in the container (doc/nvidia.md)
    # --runtime=nvidia
    # --gpus all
    # --env NVIDIA_DRIVER_CAPABILITIES="all"

    # The Docker image and command we want to run in the container always need
    # to be the last two arguments.
    "$IMAGE_NAME"
    "$SHELL"
)

# Check whether the container is running already.
# https://stackoverflow.com/a/43723174
if ! docker container inspect -f '{{.State.Running}}' "$CONTAINER_NAME" &> /dev/null; then
    docker run "${args[@]}"
else
    # Warning: This shell will be killed when the main shell exits.
    # TODO(elvout): Should we just detach the container? If we detach the
    #   container, what is the correct behavior after the image is rebuilt?
    docker exec --interactive --tty "$CONTAINER_NAME" "$SHELL"
fi
