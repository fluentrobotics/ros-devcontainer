FROM osrf/ros:jazzy-desktop-full

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Detroit

# Install commonly-used development tools.
RUN apt-get update && apt-get install --yes \
    build-essential \
    clang \
    clang-format \
    cmake \
    g++ \
    gdb \
    git \
    nano \
    ninja-build \
    valgrind \
    vim

# Install commonly-used Python tools.
RUN apt-get update && apt-get install --yes \
    python-is-python3 \
    python3-pip \
    python3-venv
RUN pip3 install --break-system-packages --upgrade uv

# Install commonly-used command-line tools.
RUN apt-get update && apt-get install --yes \
    curl \
    ffmpeg \
    iproute2 \
    iputils-ping \
    less \
    mesa-utils \
    net-tools \
    parallel \
    rsync \
    software-properties-common \
    tmux \
    tree \
    unzip \
    usbutils \
    wget \
    xxhash \
    zip \
    zsh \
    zstd

# "Nimbus Roman" font for IEEE LaTeX figures.
RUN apt-get update && apt-get install --yes fonts-urw-base35

# Neobotix + UR workflows
RUN apt-get update && apt-get install --yes \
    ros-jazzy-cyclonedds \
    ros-jazzy-rmw-cyclonedds-cpp \
    "ros-jazzy-ur-*" \
    ros-jazzy-ros2controlcli \
    ros-jazzy-moveit \
    ros-jazzy-rosbridge-suite

# Devcontainer
RUN apt-get update && apt-get install --yes sudo \
    && useradd --create-home --shell /bin/bash vscode \
    && printf '%s\n' "vscode ALL=(root) NOPASSWD: /usr/bin/apt, /usr/bin/apt-get, /usr/bin/dpkg" > /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode

# Codex sandboxing
RUN apt-get update && apt-get install --yes bubblewrap
