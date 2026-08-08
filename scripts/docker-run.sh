#!/usr/bin/env sh
# Run the opencode development image with the current directory mounted at
# /workspace.
#
# Optional environment:
#   OPENCODE_IMAGE   image to run (default: sfuhrm/opencode-docker)
#
# Usage:
#   ./scripts/docker-run.sh                     # interactive shell
#   ./scripts/docker-run.sh mvn clean install   # run a command instead
set -eu

IMAGE="${OPENCODE_IMAGE:-sfuhrm/opencode-docker}"
WORKSPACE="$(pwd)"

docker run -it --rm \
    -v "$WORKSPACE:/workspace" \
    -w /workspace \
    "$IMAGE" "$@"
