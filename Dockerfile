FROM debian:13

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        maven \
        gradle \
        unzip \
        screen \
        openjdk-25-jdk 2>/dev/null || \
        (apt-get install -y --no-install-recommends openjdk-17-jdk || apt-get install -y --no-install-recommends openjdk-21-jdk || true) && \
    curl -fsSL https://opencode.ai/install | bash && \
    ln -sf /root/.opencode/bin/opencode /usr/local/bin/opencode && \
    useradd -m user && \
    mkdir -p /workspace && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
USER user

CMD ["opencode"]
