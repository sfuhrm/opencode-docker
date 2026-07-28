# opencode Development Environment

![License](https://img.shields.io/github/license/sfuhrm/opencode-docker?color=blue)
![GitHub Actions](https://img.shields.io/github/actions/workflow/status/sfuhrm/opencode-docker/docker.yml?label=GHCR)
![Docker Pulls](https://img.shields.io/docker/pulls/sfuhrm/opencode-docker?label=Dockerhub%20Pulls)
![Image Size](https://img.shields.io/docker/image-size/sfuhrm/opencode-docker/master?label=image%20size)

Docker container with Java development tools and opencode CLI.

## Included Tools

- OpenJDK 25
- Apache Maven 3.9.16
- Gradle 9.6.1
- opencode CLI
- curl, ca-certificates, unzip, screen

## Quick Start

```bash
docker run -it sfuhrm/opencode-docker
```

## Volumes & Mounting

Mount your local project directory into the container:

```bash
docker run -it -v $(pwd):/workspace sfuhrm/opencode-docker
```

### Persist Maven/Gradle Cache

```bash
docker run -it \
  -v $(pwd):/workspace \
  -v maven-cache:/root/.m2 \
  -v gradle-cache:/root/.gradle \
  sfuhrm/opencode-docker
```

### Mount SSH Keys (for Git access)

```bash
docker run -it \
  -v $(pwd):/workspace \
  -v ~/.ssh:/home/user/.ssh:ro \
  sfuhrm/opencode-docker
```

## Use Cases

| Use Case | Command |
|----------|---------|
| Interactive development | `docker run -it -v $(pwd):/workspace sfuhrm/opencode-docker` |
| Run Maven build | `docker run -it -v $(pwd):/workspace sfuhrm/opencode-docker mvn clean install` |
| Run Gradle build | `docker run -it -v $(pwd):/workspace sfuhrm/opencode-docker gradle build` |
| One-off command | `docker run --rm -v $(pwd):/workspace sfuhrm/opencode-docker mvn -version` |
| Background screen session | `docker run -d -v $(pwd):/workspace sfuhrm/opencode-docker screen -S dev` |

## Build

```bash
docker build -t opencode-docker .
```

Override versions with build args:

```bash
docker build --build-arg MAVEN_VERSION=3.9.16 --build-arg GRADLE_VERSION=9.6.1 -t opencode-docker .
```

## Multi-Platform Build

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t opencode-docker --push .
```
