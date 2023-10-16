# ROS Noetic Docker Configuration

Table of Contents

- [Introduction](#introduction)
- [Docker Jargon](#docker-jargon)
- [Motivation](#motivation)
- [Disclaimers and Major Limitations](#disclaimers-and-major-limitations)
- [Getting Started](#getting-started)
  - [Install Docker Engine](#install-docker-engine)
  - [Docker Engine Post-Installation Steps](#docker-engine-post-installation-steps)
  - [Set Up ROS Noetic In Your Shell Environment](#set-up-ros-noetic-in-your-shell-environment)
  - [Using ROS](#using-ros)
  - [Making Changes](#making-changes)
- [Contributing](#contributing)

## Introduction

A lot of existing robotics infrastructure is built on ROS 1 Noetic, including
the software running on our robots. If we're lucky, we can simply install Ubuntu
20.04 and ROS Noetic on our personal or lab computer and we'll have an
environment that we can develop and run programs in. However, nowadays it's
possible that your computer's hardware is "too new" for Ubuntu 20.04, and you
may encounter hardware/driver issues (e.g., wifi, bluetooth, graphics). This
problem can probably be solved by finding and backporting appropriate drivers
and/or compiling a newer kernel, but these tasks can be challenging. This Docker
configuration serves an alternative solution, provided that some newer version
of Ubuntu\* _just works™_ on your hardware and you are okay with a moderate
level of inconvenience in a terminal environment every time you need to use ROS
Noetic or install some package for ROS.

\*In particular, Ubuntu 22.04 LTS or one of the other [Ubuntu versions currently
supported by Docker][supported-ubuntu-versions].

[supported-ubuntu-versions]: https://docs.docker.com/engine/install/ubuntu/#os-requirements

## Docker Jargon

If you're relatively new to Docker, we will use the following terms and informal
definitions throughout this document:

- Host (system): The operating system that you see and log into when your
  computer boots up.
- Dockerfile: A specification format and filename used by Docker.
- (Docker) Image: A "file" that is built from a Dockerfile and executable by
  Docker. Analogous to a VM snapshot or an executable program compiled from
  source code.
- (Docker) Container: A running instance of of a Docker image. Analogous to an
  active VM or a running process.

For a more formal treatment, we direct you to Docker's official
[glossary][glossary] and [overview][overview] or various blog posts and
tutorials about Docker on the Internet.

[glossary]: https://docs.docker.com/glossary/
[overview]: https://docs.docker.com/get-started/overview/

## Motivation

The Open Source Robotics Foundation builds, maintains, and publishes Docker
images for ROS. These images may already be sufficient for your use case. This
goal of repository is to build upon the `osrf/ros:noetic-desktop-full` image to:

- Install various commonly-used command-line development tools and utilities.
- Enable GUI applications within the Docker container.
- Provide a shell environment in the Docker container that is as close as
  possible to the shell environment on the host.
- Provide a relatively simple configuration that is easy to understand for new
  Docker users.
- Provide documentation/HOWTOs to help new Docker users figure out how to make
  modifications to this configuration for their specific use cases.

Importantly, the last two points mean that **this configuration probably won't
work for your use case as-is and you will need to make appropriate
modifications!** There will only be one configuration -- one Dockerfile -- in
each git branch at any given time. We may create additional git branches for
commonly-used alternative (e.g., project-specific) configurations in the future.

## Disclaimers and Major Limitations

To reduce the number of specification formats the user needs to learn, we will
not be using Docker Compose. Everything that may typically go into `compose.yaml`
will instead be specified as arguments to `docker run`.

> [!WARNING]
> All containers will be ephemeral, meaning that all processes inside the
> container will be terminated immediately and without warning when the main
> shell session inside the container exits. This applies even if you open a
> `tmux` session inside the container -- the `tmux` server itself will be
> terminated!
>
> **🚨DO NOT USE THIS CONFIGURATION AS-IS ON A ROBOT, ESPECIALLY VIA
> A REMOTE CONNECTION!🚨**

We assume that this configuration will be used on a single-user machine. This
reduces some engineering overhead as we won't have to consider how one user's
modifications to the Docker image affects all other potential users.

We assume that the user does not require GUI applications or an X11 server when
starting the Docker container remotely, e.g., over SSH.

You may have used Docker before to provide isolation between software and the
host system. This repository intentionally takes a very relaxed approach to
security, breaking container isolation to create a more convenient development
environment. In particular, please be advised that changes to many parts of the
filesystem within the Docker container will be mapped directly and immediately
back to the host filesystem. Additionally, any user granted the [`docker`
group][docker-group] as part of the installation steps is effectively granted
`root` access on the host.

[docker-group]: https://docs.docker.com/engine/install/linux-postinstall/

## Getting Started

### Install Docker Engine

Before we provide a documentation link, note that the Docker documentation will
try _very hard_ to have you install "Docker Desktop" instead, which essentially
runs Docker Engine in a Linux virtual machine and is not necessary if you're
already on Linux (which we are). If you've installed Docker Desktop (or already
have it installed for some other application), the rest of the setup may still
work, but we only test this repository with Docker Engine.

In the linked page, ignore anything to do with Docker Desktop. You can find
official instructions for installing the **latest version** of Docker Engine
**using the Apt repository** [in this link][docker-engine-ubuntu].

[docker-engine-ubuntu]: https://docs.docker.com/engine/install/ubuntu

### Docker Engine Post-Installation Steps

Adapted from the [official documentation][docker-postinstall].

It is very likely that most `docker` commands will print out a "permission
denied" error right after installation:

```shell
$ docker run --rm hello-world
permission denied while trying to connect to the Docker daemon socket at
unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/images/json":
dial unix /var/run/docker.sock: connect: permission denied
```

This is expected behavior. To grant permissions non-root users (this includes
yourself), run the following commands in a terminal. You may be prompted for
your password.

- `sudo groupadd docker`
- `sudo usermod -aG docker $USER`

You'll then need to log out and log back in. Afterwards, you should be able
to use `docker` commands.

```shell
# Note: truncated output
$ docker run --rm hello-world
...
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

[docker-postinstall]: https://docs.docker.com/engine/install/linux-postinstall/

### Set Up ROS Noetic In Your Shell Environment

See [`doc/ros-shell-environment.md`](doc/ros-shell-environment.md).

> [!NOTE]
> The remaining steps assume you have followed the recommended instructions in
> the above document.

### Using ROS

When you run this command for the first time, it will build a Docker image from
the [`Dockerfile`](./Dockerfile), which may take a good amount of time depending
on your internet connection. Afterwards, it will drop you into a shell inside of
an ephemeral container.

```shell
./enter-container.sh
```

Your shell may be configured to display the current hostname, which is useful
for determining whether you are currently looking at the Docker container or the
host system. For example,

```shell
# A shell on your host system may look like this:
your-username@your-computer-name:~$

# While a shell in the Docker container would look like this:
your-username@fluentrobotics/ros:noetic-desktop-gui:~$
```

If you find that a long hostname is cumbersome, you can customize the `--hostname`
argument in [`./enter-container.sh`](./enter-container.sh).

Once you're inside the Docker container, you can navigate around your home
folder and begin to use ROS.

``` shell
$ pwd
/home/your-username

$ ls
... # Files in your home directory

# Launch roscore in the background.
$ roscore &

# Press enter until you see the shell prompt again.
$

$ rostopic list
/rosout
/rosout_agg

# Launch rviz in the background.
# rviz should open a GUI window that you can interact with.
$ rviz &
```

You can exit the container using the `exit` command or with the shortcut
`Control-D`.

Subsequent invocations of [`./enter-container.sh`](./enter-container.sh) will
use the Docker image that was built at some point in the past. Whenever you make
changes to the [`Dockerfile`](./Dockerfile), you will need to manually rebuild
the image on the host system using this command:

```shell
./build-image.sh
```

### Making Changes

In this example, we're going to install [GTSAM](https://gtsam.org/) inside the
Docker image. For convenience, we'll use the prebuilt packages that are
published by the authors.

The authors provide installation instructions [here][gtsam-install] (Install
GTSAM from Ubuntu PPA; stable release) that look like this if we were to run
them on a Ubuntu 20.04 host. We need to modify them slightly so they'll work in
the [`Dockerfile`](./Dockerfile).

```shell
# Add PPA
sudo add-apt-repository ppa:borglab/gtsam-release-4.0
sudo apt update  # not necessary since Bionic
# Install:
sudo apt install libgtsam-dev libgtsam-unstable-dev
```

We'll make the following changes:

1. Prepend `RUN` to all the commands.
2. Drop `sudo` from the commands. All commands run as the `root` user in a
   Dockerfile by default.
3. Add the `--yes` argument to the `apt install` command. Usually `apt install`
   will wait for the user to type "yes" in the terminal before actually
   installing anything. The `--yes` argument is built into `apt install` in case
   you want to specify confirmation ahead of time, e.g., if you're using an
   automated install process.

```Dockerfile
# Install GTSAM 4.x stable. (https://gtsam.org/get_started)
RUN add-apt-repository ppa:borglab/gtsam-release-4.0
RUN apt update
RUN apt install --yes libgtsam-dev libgtsam-unstable-dev
```

Adding these four lines to the end of the [`Dockerfile`](./Dockerfile) installs
GTSAM when the Docker image is built.

> [!IMPORTANT]
> Remember to run `./build-image.sh` to rebuild the Docker image after making
> changes in the Dockerfile!

More complex modifications will be available in the [`doc/`](doc/) folder in the
future, including support for things like CUDA and audio applications while
inside the container.

[gtsam-install]: https://gtsam.org/get_started/

## Contributing

Please submit issues and/or pull requests for anything from reporting broken
tooling to suggestions and improvements for code and documentation.

This development status of this repository will be in alpha for the forseeable
future. At this time, we cannot guarantee any form of support or warranty for
users outside of our lab.
