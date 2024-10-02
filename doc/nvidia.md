# Using NVIDIA GPUs in Docker

This document outlines how to enable the CUDA runtime inside Docker on computers
with NVIDIA GPUs.

## Install NVIDIA Drivers on the Host System

If NVIDIA drivers have not been installed yet, follow the instructions from
[Ubuntu][ubuntu-nvidia-install] to install NVIDIA Driver version
`nvidia-driver-535` (the current stable version as of Oct. 2023) on the host
Ubuntu.

Read through the section named "The recommended way (ubuntu-drivers tool)". The
command that you end up running at the end should be:

```shell
sudo ubuntu-drivers install nvidia:535
```

After the drivers are done installing on the host (this might take some time and
require a reboot), you should be able to run the `nvidia-smi` command in a
terminal to obtain output that resembles below:

```shell
$ nvidia-smi
Sun Oct 29 15:09:27 2023
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.113.01             Driver Version: 535.113.01   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA RTX A2000 12GB          Off | 00000000:01:00.0  On |                  Off |
| 30%   37C    P8               9W /  70W |    678MiB / 12282MiB |     12%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+

+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|    0   N/A  N/A    484602      G   /usr/lib/xorg/Xorg                          219MiB |
|    0   N/A  N/A    484772      G   /usr/bin/gnome-shell                         91MiB |
+---------------------------------------------------------------------------------------+

```

[ubuntu-nvidia-install]: https://ubuntu.com/server/docs/nvidia-drivers-installation

## Install the `nvidia-container-toolkit`

Follow the sections titled "Installing with Apt" and "Configuring Docker" from
[NVIDIA][nvidia-toolkit] to install the `nvidia-container-toolkit`.

Afterwards, follow "Running a Sample Workload with Docker" from the [next
page][sample-workload] in the documentation. The output should be essentially
identical to the result of running `nvidia-smi` on the host.

[nvidia-toolkit]: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
[sample-workload]: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/sample-workload.html

## Configuring the Container

In the [enter-container.sh](/enter-container.sh) script, uncomment the following
lines in the `args` array:

```bash
--runtime=nvidia
--gpus all
--env NVIDIA_DRIVER_CAPABILITIES="all"
```

If the container is currently running, it will need to be stopped for this
change to take effect.

```shell
# Example
docker stop -t 0 ros-noetic
```

### Option 1: Most Workflows (e.g. PyTorch)

When you re-enter the container, you should be able to use your computer's NVIDIA
GPUs.

### Option 2: CUDA Development Workflows

If your workflow needs CUDA Development tools (e.g., compiling kernels), use one
of the images that end in `-cuXYZ`.

```shell
# Example
./build-image.sh noetic-cu118
./enter-container.sh noetic-cu118
```
