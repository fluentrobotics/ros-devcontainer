FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Detroit

# Install ROS 2 Humble. There might be a more elegant way of doing this using
# multi-stage builds.
# https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html
RUN apt-get update && apt-get install --yes locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN apt-get update && apt-get install --yes software-properties-common
RUN add-apt-repository universe

RUN apt-get update && apt-get install --yes curl
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
# ROS 2 Humble installation instructions recommend running apt upgrade
RUN apt-get update && apt-get upgrade --yes && apt-get install --yes ros-humble-desktop-full
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
RUN pip3 install --upgrade mypy virtualenv

# Generate type stubs for rclpy using mypy
RUN stubgen --include-docstrings \
    /opt/ros/humble/local/lib/python3.10/dist-packages/rclpy \
    --output /opt/ros/humble/local/lib/python3.10/dist-packages
RUN touch /opt/ros/humble/local/lib/python3.10/dist-packages/rclpy/py.typed

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

RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/usr/local/pypoetry python3.10 -
RUN ln -s /usr/local/pypoetry/bin/* /usr/local/bin/
