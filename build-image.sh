#! /usr/bin/env bash

set -o errexit


IMAGE_NAME="fluentrobotics/ros:noetic-desktop-gui"


docker build \
    --tag "$IMAGE_NAME" \
    .
