# opencode Development Environment

Docker container with Java development tools and opencode CLI.

## Included Tools

- OpenJDK 25
- Maven
- Gradle
- opencode CLI
- curl, wget, unzip, screen

## Quick Start

```bash
docker run -it ghcr.io/<username>/opencode-dev-env
```

## Build

```bash
docker build -t opencode-dev-env .
```

## Multi-Platform Build

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t opencode-dev-env --push .
```
