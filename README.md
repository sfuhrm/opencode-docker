# opencode Development Environment

![License](https://img.shields.io/github/license/<owner>/<repo>)
![GitHub Actions](https://img.shields.io/github/actions/workflow/status/sfuhrm/opencode-docker/docker.yml?label=GHCR)
![Docker Hub](https://img.shields.io/docker/pulls/sfuhrm/opencode-docker?label=Docker%20Hub)

Docker container with Java development tools and opencode CLI.

## Included Tools

- OpenJDK 25
- Apache Maven 3.9.16
- Gradle 9.6.1
- opencode CLI
- curl, ca-certificates, unzip, screen

## Quick Start

```bash
docker run -it ghcr.io/<username>/opencode-dev-env
```

## Build

```bash
docker build -t opencode-dev-env .
```

Override versions with build args:

```bash
docker build --build-arg MAVEN_VERSION=3.9.16 --build-arg GRADLE_VERSION=9.6.1 -t opencode-dev-env .
```

## Multi-Platform Build

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t opencode-dev-env --push .
```
