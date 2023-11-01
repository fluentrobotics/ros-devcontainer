# Configuring ROS In Your Shell Environment

If you already have your own ROS shell configuration, you can probably skip over
the basic configuration.

🔔 If you prefer `zsh` over `bash`, replace most instances of `.bash` in this
document with `.zsh` and write to `~/.zshrc` instead of `~/.bashrc`. You'll also
want to change the last element of the `args` array in
[`enter-container.sh`](/enter-container.sh) from `bash` to `zsh`.

---

## Basic Configuration

### TL;DR

If your workflow runs entirely on a single computer, we recommend adding this
set of lines to your `~/.bashrc`

```bash
if [[ -f /opt/ros/noetic/setup.bash ]]; then
  source /opt/ros/noetic/setup.bash

  export ROS_MASTER_URI="http://localhost:11311"
  export ROS_IP="127.0.0.1"
fi
```

### Explanation

As stated in the [ROS installation instructions][ros-instructions], you need to
run this command in every shell environment in order to use ROS.

```shell
source /opt/ros/noetic/setup.bash
```

Doing this manually in every shell is very inconvenient, so they recommend
adding the command to your `~/.bashrc` file, which is run as part of each
shell's initialization procedure. If you do this, ROS will work in the Docker
container, but when you create a new shell on the host system you'll probably be
greeted with an error:

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

## Advanced Configuration

If you are using ROS on multiple machines over a network and you are not able to
configure static IP addresses, you may find that you often need to modify
`ROS_MASTER_URI` and `ROS_IP` and re-`source` your shell rc file. This is
particularly inconvenient when you already have multiple shells open and you
have to re-`source` in all of them.

In this section we outline additional configuration that performs two tasks:

1. Set the `ROS_IP` automatically to that of your computer's default gateway. 🔔
   This does not set up `ROS_MASTER_URI`!
2. Dynamically load changes to these environment variables so you don't have to
   manually type `source .<shell>rc` after making changes.

### Automatically Set `ROS_IP`

To set `ROS_IP` automatically, start by creating a new file, e.g. `~/.rosrc` and
add these commands to the file:

```shell
### file: ~/.rosrc

ROS_GATEWAY=$(ip route list default | cut -d " " -f 5)

export ROS_IP=$(ip -4 -br addr show $ROS_GATEWAY | tr -ts "/" " " | cut -d " " -f 3)

export ROS_MASTER_URI=http://$ROS_IP:11311
```

These commands find the default gateway of your computer and its associated IP
address while massaging the output into a format that we can use.

There are two caveats here:

1. If you know you're using a non-default gateway, e.g., a USB network adapter
   or a VPN, you'll want to manually set `ROS_GATEWAY` to the name of that
   gateway.
2. The code block above uses `ROS_IP` to set `ROS_MASTER_URI`. This is correct
   behavior for the machine that will be running `roscore`, but all other
   machines will need to have this set manually to the server's IP address
   (which may change if it's dynamic).

### Automatically Re-`source` `~/.rosrc`

We will use different features of `bash` and `zsh` to run commands automatically
in their respective shell environments.

In `bash`, this feature is the `PROMPT_COMMAND` shell variable, which runs a
command immediately before the shell prompt is drawn. Note that if the prompt is
already drawn on the screen, `PROMPT_COMMAND` will not run until the _next_ time
the prompt is drawn, so you'll need to hit enter for it to run.

In `zsh`, this feature is the `preexec` function, which runs immediately before
executing a shell command. The function does not run between chained commands;
`preexec` effectively runs the function immediately after you hit enter.

Since these features inject commands into your shell environment
behind-the-scenes, you'll want to keep the runtime of the commands as short as
possible so you don't introduce too much latency in your shell. The contents of
`~/.rosrc` above typically run in a few milliseconds.

We can update the ROS block of your shell file as follows.

Bash:

```shell
### file: ~/.bashrc

if [[ -f /opt/ros/noetic/setup.bash ]]; then
  source /opt/ros/noetic/setup.bash

  PROMPT_COMMAND="source ~/.rosrc"
fi
```

Zsh:

```shell
### file: ~/.zshrc

if [[ -f /opt/ros/noetic/setup.zsh ]]; then
  source /opt/ros/noetic/setup.zsh

  preexec() {
    source ~/.rosrc
  }
fi
```

You can check the values of ROS environment variables in either shell using

```shell
env | grep ROS
```
