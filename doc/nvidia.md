# Using NVIDIA GPUs in Docker

This document outlines how to enable the CUDA runtime inside Docker on computers
with NVIDIA GPUs.

## Install NVIDIA Drivers on the Host System

If NVIDIA drivers have not been installed yet, follow the instructions from
[Ubuntu][ubuntu-nvidia-install] to install the latest stable NVIDIA Driver
version (`nvidia-driver-550` as of Mar. 2025) on the host Ubuntu.

Read through the section named "The recommended way (ubuntu-drivers tool)". The
command that you end up running at the end should be:

```shell
sudo ubuntu-drivers install nvidia:550
```

After the drivers are done installing on the host (this might take some time and
require a reboot), you should be able to run the `nvidia-smi` command in a
terminal to obtain output that resembles below:

```shell
$ nvidia-smi
Thu Mar 13 10:54:40 2025
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.120                Driver Version: 550.120        CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 4090        Off |   00000000:01:00.0 Off |                  Off |
|  0%   44C    P8             14W /  450W |      31MiB /  24564MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A      9067      G   /usr/lib/xorg/Xorg                              9MiB |
|    0   N/A  N/A      9119      G   /usr/bin/gnome-shell                           10MiB |
+-----------------------------------------------------------------------------------------+
```

[ubuntu-nvidia-install]: https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers

## Install the `nvidia-container-toolkit`

Follow the sections "Installation->With `apt`: Ubuntu, Debian" and
"Configuration->Configuring Docker" from [NVIDIA][nvidia-toolkit] to install the
`nvidia-container-toolkit`.

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
