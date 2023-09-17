# Configuring ROS In Your Shell Environment

If you already have your own ROS shell configuration, you can probably skip this
document.

🔔 If you prefer `zsh` over `bash`, replace the `.bash` extension with `.zsh`
and write to `~/.zshrc` instead of `~/.bashrc`. You'll also want to change the
last element of the `args` array in
[`enter-container.sh`](../enter-container.sh) from `bash` to `zsh`.

---

## TL;DR

We recommend adding this set of lines to your `~/.bashrc`

```bash
if [[ -f /opt/ros/noetic/setup.bash ]]; then
  source /opt/ros/noetic/setup.bash

  export ROS_MASTER_URI="http://localhost:11311"
  export ROS_IP="127.0.0.1"
fi
```

## Explanation

As stated in the [ROS installation instructions][ros-instructions], you need to
run this command in every shell environment in order to use ROS.

```shell
source /opt/ros/noetic/setup.bash
```

Doing this manually every time is very inconvenient, so they recommend adding
the command to your `~/.bashrc` file, which is run as part of each shell's
initialization procedure. If you do this, ROS will work in the Docker container,
but when you create a new shell on the host system you'll probably be greeted
with an error:

> bash: /opt/ros/noetic/setup.bash: No such file or directory

`bash` is telling you that the file `/opt/ros/noetic/setup.bash` does not exist
on the host system. Note that this shouldn't cause any adverse effects on the
host, but you might find this message annoying. We can handle the error by
checking whether the file exists before trying to `source` it:

```bash
if [[ -f /opt/ros/noetic/setup.bash ]]; then
  source /opt/ros/noetic/setup.bash
fi
```

The `if` statement should evaluate to `false` on the host and `true` inside the
Docker container.

Lastly, we'll set some environment variables so ROS can find resources on the
network.

```bash
if [[ -f /opt/ros/noetic/setup.bash ]]; then
  source /opt/ros/noetic/setup.bash

  export ROS_MASTER_URI="http://localhost:11311"
  export ROS_IP="127.0.0.1"
fi
```

The code block above assumes that you're only using ROS on your local machine.
You will need to modify the variables accordingly if you need multiple machines
to communicate with one another over a network.

`ROS_MASTER_URI` specifies the address of the `roscore` server and, implicitly,
the network interface ROS is using on the server. The `ROS_MASTER_URI` address
should be reachable through every systems's `ROS_IP` address and corresponding
network interface.

`ROS_IP` specifies the IP address for this system and, implicitly, the network
interface that ROS should use to connect to the `roscore` server. If
`ROS_HOSTNAME` is also set, `ROS_HOSTNAME` will take precedence over `ROS_IP`,
but hostname resolution might not be available in all situations.

You can find the full list of ROS 1 environment variables [here][ros-env-vars].
Most of them do not need to be changed from their default values.

[ros-instructions]: https://wiki.ros.org/noetic/Installation/Ubuntu#noetic.2FInstallation.2FDebEnvironment.Environment_setup>

[ros-env-vars]: https://wiki.ros.org/ROS/EnvironmentVariables
