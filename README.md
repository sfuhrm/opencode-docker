# opencode Java Development Environment

![License](https://img.shields.io/github/license/sfuhrm/opencode-docker?color=blue)
![GitHub Actions](https://img.shields.io/github/actions/workflow/status/sfuhrm/opencode-docker/docker.yml?label=GHCR)
![Docker Pulls](https://img.shields.io/docker/pulls/sfuhrm/opencode-docker?label=Dockerhub%20Pulls)
![Image Size](https://img.shields.io/docker/image-size/sfuhrm/opencode-docker/master?label=image%20size)

[Docker image](https://hub.docker.com/r/sfuhrm/opencode-docker) with Java development tools and opencode CLI.

The container runs as a non-root user `user` (home directory `/home/user`).

## Included Tools

- OpenJDK 25
- Apache Maven 3.9.16
- Gradle 9.6.1
- opencode CLI 1.18.15
- OpenSpec CLI 1.8.0 (Node.js 24 + npm)
- Docker CLI with `docker compose` (connect to a host daemon via socket)
- bash, curl, ca-certificates, unzip, tar, screen

## Quick Start

```bash
docker run -it --rm sfuhrm/opencode-docker
```

## Volumes & Mounting

Mount your local project directory into the container:

```bash
docker run -it --rm -v $(pwd):/workspace sfuhrm/opencode-docker
```

### Persist Maven/Gradle Cache

```bash
docker run -it \
  -v $(pwd):/workspace \
  -v maven-cache:/home/user/.m2 \
  -v gradle-cache:/home/user/.gradle \
  sfuhrm/opencode-docker
```

### Persist opencode Config & Auth

```bash
docker run -it \
  -v $(pwd):/workspace \
  -v opencode-config:/home/user/.config/opencode \
  -v opencode-data:/home/user/.local/share/opencode \
  sfuhrm/opencode-docker
```

### Mount SSH Keys (for Git access)

```bash
docker run -it \
  -v $(pwd):/workspace \
  -v ~/.ssh:/home/user/.ssh:ro \
  sfuhrm/opencode-docker
```

### Use Docker from the Container

The image ships with the Docker CLI (including `docker compose`). Point it at your host daemon by mounting the Docker socket:

```bash
docker run -it \
  -v $(pwd):/workspace \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add "$(getent group docker | cut -d: -f3)" \
  sfuhrm/opencode-docker
```

`--group-add` maps your host's `docker` group ID into the container so the non-root `user` can access the socket. Alternatively, run with `--user root`.

## Use Cases

| Use Case | Command |
|----------|---------|
| Interactive development | `docker run -it --rm -v $(pwd):/workspace sfuhrm/opencode-docker` |
| Run Maven build | `docker run -it --rm -v $(pwd):/workspace sfuhrm/opencode-docker mvn clean install` |
| Run Gradle build | `docker run -it --rm -v $(pwd):/workspace sfuhrm/opencode-docker gradle build` |
| One-off command | `docker run --rm -v $(pwd):/workspace sfuhrm/opencode-docker mvn -version` |
| Background screen session | `docker run -d -v $(pwd):/workspace sfuhrm/opencode-docker screen -S dev` |

## Build

```bash
docker build -t opencode-docker .
```

Override versions with build args:

```bash
docker build \
  --build-arg MAVEN_VERSION=3.9.16 \
  --build-arg GRADLE_VERSION=9.6.1 \
  --build-arg OPENCODE_VERSION=1.18.15 \
  --build-arg OPENSPEC_VERSION=1.8.0 \
  -t opencode-docker .
```

## Multi-Platform Build

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t opencode-docker --push .
```
