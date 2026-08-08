#!/usr/bin/env sh
# Run the opencode development image with a Docker-in-Docker daemon sidecar,
# so `docker`, `docker compose`, and `docker build` work from inside the
# container without relying on the host daemon.
#
# Optional environment:
#   OPENCODE_IMAGE   dev image to run            (default: sfuhrm/opencode-docker)
#   DIND_IMAGE       sidecar daemon image        (default: docker:29.7.1-dind)
#   DIND_NAME        sidecar container name      (default: opencode-dind)
#   NETWORK          shared bridge network       (default: opencode-dind-net)
#   DATA_VOLUME      daemon data volume          (default: opencode-dind-data)
#
# Notes:
#   - The sidecar runs with --privileged (required for nested Docker).
#   - The daemon listens on TCP port 2375 WITHOUT TLS on an isolated Docker
#     network. Fine for local development, not for public exposure.
#   - Stop the daemon later with: docker rm -f opencode-dind
set -eu

IMAGE="${OPENCODE_IMAGE:-sfuhrm/opencode-docker}"
DIND_IMAGE="${DIND_IMAGE:-docker:29.7.1-dind}"
DIND_NAME="${DIND_NAME:-opencode-dind}"
NETWORK="${NETWORK:-opencode-dind-net}"
DATA_VOLUME="${DATA_VOLUME:-opencode-dind-data}"
WORKSPACE="$(pwd)"

docker network inspect "$NETWORK" >/dev/null 2>&1 || docker network create "$NETWORK" >/dev/null

if ! docker inspect "$DIND_NAME" >/dev/null 2>&1; then
    echo "Starting Docker daemon sidecar '$DIND_NAME'..."
    docker run -d --privileged \
        --name "$DIND_NAME" \
        --network "$NETWORK" \
        -e DOCKER_TLS_CERTDIR= \
        -v "$DATA_VOLUME:/var/lib/docker" \
        --restart unless-stopped \
        "$DIND_IMAGE" >/dev/null
elif [ "$(docker inspect -f '{{.State.Running}}' "$DIND_NAME")" != "true" ]; then
    echo "Starting existing Docker daemon sidecar '$DIND_NAME'..."
    docker start "$DIND_NAME" >/dev/null
fi

echo "Waiting for the Docker daemon to come up..."
i=0
until docker exec "$DIND_NAME" docker info >/dev/null 2>&1; do
    i=$((i + 1))
    if [ "$i" -ge 30 ]; then
        echo "error: Docker daemon did not start in time" >&2
        exit 1
    fi
    sleep 1
done

echo "Starting '$IMAGE' with '$WORKSPACE' mounted at /workspace..."
docker run -it --rm \
    -v "$WORKSPACE:/workspace" \
    -w /workspace \
    -e "DOCKER_HOST=tcp://$DIND_NAME:2375" \
    --network "$NETWORK" \
    "$IMAGE" "$@"
