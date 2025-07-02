FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Detroit

# Install ROS 2 Jazzy.
# https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html
RUN apt-get update && apt-get install --yes locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN apt-get update && apt-get install --yes software-properties-common
RUN add-apt-repository universe
RUN apt-get update && apt-get install --yes curl
RUN export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}'); \
    curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb"
RUN dpkg -i /tmp/ros2-apt-source.deb
# ROS 2 Jazzy installation instructions recommend running apt upgrade
RUN apt-get update && apt-get upgrade --yes && apt-get install --yes ros-jazzy-desktop-full
RUN apt-get update && apt-get install --yes \
    python3-colcon-common-extensions \
    python3-rosdep

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
    iproute2 \
    iputils-ping \
    less \
    mesa-utils \
    net-tools \
    parallel \
    rsync \
    software-properties-common \
    sudo \
    tmux \
    tree \
    unzip \
    usbutils \
    wget \
    xxhash \
    zip \
    zsh \
    zstd

# Install fonts for matplotlib
RUN apt-get update && apt-get install -y fonts-urw-base35
