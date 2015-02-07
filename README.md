# docker-builder-pattern
Docker Builder Pattern is a tool to build projects in standardized build environment using Docker.

# Requirements
Builder must have a working Docker installation. Bash is also needed.

# How to run?

```bash
    wget https://raw.githubusercontent.com/sirkkalap/docker-builder-pattern/master/example.sh \
      && bash ./example.sh
```

# Why standardized builds?
- Builds can be repeated.
- Dependencies become explicit and defined.
- Work can be distributed
- Failures can be reproduced
- Automated builds are easier to maintain
- Bug reports can contain a repeatable build script

# Why not?
- Takes slightly more time.
- Uses Docker, which requires understanding.
- Docker is not for everyone. No .Net yet.
- Debugging is slightly more complicated.
- Even with Docker, there still are variables.

# How does it work?
Build is run inside a Docker container. The container is based on a image that has the required tools inside it.
Script mounts the current working directory inside the builder container.
This allows easy prototyping and keeps the build artifacts available to host.
