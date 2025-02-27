# Some Advanced Docker Commands

Here are some advanced docker commands that I have experienced over a period of time that you may find usefull

## docker system

If you just simply put in the command shown below in the terminal it will show the us all the options available for this command

```bash
docker system
```

Most widely used commands from `docker system` domain are:

### docker system df

This is used to check the disk storage used by docker, it is very helpful when you are struggling with the disk space full issues and want to know how much storage docker is using

```bash
docker system df
```

### docker system prune

This command is used to clear all the dangling resources of docker,

*use this command with caution*

```bash
docker system prune
```

If you are using it in the context of a script, you can use `-f` flag to bypass the user input prompt

## docker image

There are many commands with docker image like `docker images` or `docker rmi` which you must be familier but there is one more an less destructive command as compared to `docker system prune` which only takes care of dangling images:

```bash
docker image prune
```

The above command will take care of all the dangling images like if you pulled an image from a remote registry with a latest tag and that image was updated over time and when you pull again the latest image the previous image will have no tag and will be a dangling image which you can remove using `docker image prune` command.

But if you want to delete all the unused images on the server and that are not attached to any container you can use the following command to take care of that

```bash
docker image prune -a
```

If you are using it in context of a script you can use `-f` flag along with it.

## docker context

Docker contexts allow you to switch between different Docker environments (like local, remote servers, or cloud-based Docker setups).

You're using Docker Desktop but also manage remote Docker hosts. You need to check available contexts.

```bash
docker context list
```

*If using Docker Desktop, always revert back to:*
```bash
docker context use default
```

To create a new context:

```bash
docker context create <name> --description "some description" --docker "host=ssh://user@remote-server-address"
```

Switch to a different context.

```bash
docker context use <remote context name>
```

To switch back to the default local Docker:

```bash
docker context use default
```

## docker cp

Copies a file from your host machine to a running container. 
You want to copy a config file to a container.

```bash
docker cp myconfig.conf my-container:/etc/myconfig.conf
```

It also works with Docker contexts:

```bash
docker --context=my-remote-server cp myconfig.conf my-container:/etc/myconfig.conf
```

## docker logs

`docker logs` is pretty common command that is used for debugging around that domain.

One of the example use cases that i have used it with is:

```bash
docker logs my-app 2>&1 | grep -E 'error.*database'
```

## docker exec

Opens an interactive shell inside a running container.

You need to troubleshoot a running container and check files inside it.

```bash
docker exec -it my-container bash
```

If the container doesn’t have `bash`, use `sh`:

```bash
docker exec -it my-container sh
```

For debugging puproses we can use a specific conatiner that comes built in pre loaded with many troubleshooting utilities

```bash
docker run --rm --name netshoot -it nicolaka/netshoot /bin/bash
```

Inside netshoot, you can use tools like `ping`, `curl`, and `tcpdump`.

## docker commit

You manually configured software inside a running container and want to save it as an image.

```bash
docker commit my-container my-custom-image
```

You can now reuse `my-custom-image` without reconfiguring everything.

## docker save

You want to transfer an image to another system without re-downloading it. The below command saves the image in `.tar` file

```bash
docker save -o myimage.tar my-custom-image
```

## docker load

Loads a previously saved Docker image from a `.tar` file.

On another system, you want to restore an image from a `.tar` file.

```bash
docker load -i myimage.tar
```


## docker pause/unpause

You have a running container but want to temporarily freeze it (e.g., to free up CPU cycles for something else).

```bash
docker pause my-container
```

The container remains in memory but doesn’t use CPU.

You previously paused a container and now want to continue running it.

```bash
docker unpause my-container
```

## docker kill

Forces a container to stop immediately (like kill -9 in Linux).

A container is unresponsive, and docker stop isn’t working.

```bash
docker kill my-container
```

## docker top

You suspect a container is consuming too many resources and want to check its active processes.

```bash
docker top my-container
```

## docker stats

You want to monitor how much CPU and memory each container is using.

```bash
docker stats
```

If you want to check a specific container:

```bash
docker stats my-container
```

## docker wait

You want to check when a specific container finishes running before proceeding with another command.

```bash
docker wait my-container
```

If `my-container` is running a long process, this command will pause until the container stops and then return the exit status.

## docker attach

You started a container in detached mode (-d) and now want to see its live output or interact with it.

```bash
docker attach my-container
```

*warning: Pressing ``Ctrl+C`` may stop the container unless you started it with ``-it``.*

If you only need to see logs, consider using:

```bash
docker logs -f my-container
```

**Hope It was helpful 🚀** 