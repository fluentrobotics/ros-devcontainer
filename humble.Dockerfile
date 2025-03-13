
FROM osrf/ros:humble-desktop-full

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
RUN pip3 install --upgrade mypy uv virtualenv

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
