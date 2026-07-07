# ROS 2 Docker + Devcontainer Environment

This repository builds upon the official `osrf/ros` images to

- Install various commonly-used command-line development tools and utilities.
- Support GUI applications.
- Provide low-friction development and shell environments.

> [!IMPORTANT]
> This repository assumes you are already familiar with Docker. A relaxed
> approach to security is adopted for dev environment conveniences (e.g.,
> filesystem, device, user mapping). The container user is effectively a root
> user on the host. Use agentic tools at your own risk.

## Getting Started

This repository is regularly used with rootful Docker on an Ubuntu host.
Rootless Docker or Podman may require additional configuration.

If not done already,

- Install [Docker Engine][docker-engine-ubuntu]
- Follow [Post-Installation steps][docker-postinstall]
- Set up [NVIDIA drivers and container toolkit](/doc/nvidia.md) if applicable

Using `jazzy` as an example,

- Build an image: `./build-image.sh jazzy`

For shell tasks,

- Enter a shell in the container: `./enter-container.sh jazzy`

For vscode,

- Install the `Dev Containers` extension
- Copy [devcontainer.json](/devcontainer.json) to
  `.devcontainer/devcontainer.json` in your workspace.
- A popup will probably appear in the bottom right to use the devcontainer. In
  general, you can also open the command palette and use "Dev Containers:
  Rebuild and Reopen in Container".
- You should then be able to open the repository directly in the devcontainer in
  the "Open Recent" menu.

[docker-engine-ubuntu]: https://docs.docker.com/engine/install/ubuntu
[docker-postinstall]: https://docs.docker.com/engine/install/linux-postinstall/
