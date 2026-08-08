FROM eclipse-temurin:25-jdk-alpine AS builder

ARG MAVEN_VERSION=3.9.16
ARG GRADLE_VERSION=9.6.1
ARG OPENCODE_VERSION=1.18.15

RUN set -euo pipefail && \
    apk add --no-cache bash curl ca-certificates unzip tar

RUN set -euo pipefail && \
    opencode_arch="$(uname -m)" && \
    opencode_arch="$(printf '%s' "$opencode_arch" | sed -e 's/x86_64/x64/' -e 's/aarch64/arm64/')" && \
    if [ "$opencode_arch" = "x64" ] && ! grep -qwi avx2 /proc/cpuinfo; then opencode_arch="x64-baseline"; fi && \
    case "$opencode_arch" in x64|x64-baseline|arm64) ;; *) echo "Unsupported arch: $opencode_arch" >&2; exit 1 ;; esac && \
    curl -fsSL --retry 3 "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-${opencode_arch}-musl.tar.gz" -o /tmp/opencode.tar.gz && \
    case "$opencode_arch" in \
      x64)          expected_opencode="229db770e17f4e493bff8e516b2f191f4ea3430b35f5e6f458c94f4ce7edc01f" ;; \
      x64-baseline) expected_opencode="73ae90210eb93192b64d8409b9ea70fb151b7a73ac5f49739e170066a253b88f" ;; \
      arm64)        expected_opencode="134d46c15c184ed9d5fce7c93423b4040dcdc8547f23fc425e6a7b51e166e18a" ;; \
      *) echo "Unsupported arch: $opencode_arch" >&2; exit 1 ;; \
    esac && \
    actual_opencode="$(sha256sum /tmp/opencode.tar.gz | awk '{print $1}')" && \
    [ "$expected_opencode" = "$actual_opencode" ] && \
    mkdir -p "$HOME/.opencode/bin" && \
    tar -xzf /tmp/opencode.tar.gz -C "$HOME/.opencode/bin" && \
    rm /tmp/opencode.tar.gz

RUN set -euo pipefail && \
    curl -fsSL --retry 3 https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -o /tmp/maven.tar.gz && \
    curl -fsSL https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512 -o /tmp/maven.tar.gz.sha512 && \
    expected_maven="$(tr -d '[:space:]' < /tmp/maven.tar.gz.sha512)" && \
    actual_maven="$(sha512sum /tmp/maven.tar.gz | awk '{print $1}')" && \
    [ "$expected_maven" = "$actual_maven" ] && \
    tar -xz -C /opt -f /tmp/maven.tar.gz && \
    rm /tmp/maven.tar.gz /tmp/maven.tar.gz.sha512 && \
    rm -rf /opt/apache-maven-${MAVEN_VERSION}/src \
           /opt/apache-maven-${MAVEN_VERSION}/docs

RUN set -euo pipefail && \
    curl -fsSL --retry 3 https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle.zip && \
    curl -fsSL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip.sha256 -o /tmp/gradle.zip.sha256 && \
    expected_gradle="$(tr -d '[:space:]' < /tmp/gradle.zip.sha256)" && \
    actual_gradle="$(sha256sum /tmp/gradle.zip | awk '{print $1}')" && \
    [ "$expected_gradle" = "$actual_gradle" ] && \
    unzip -q /tmp/gradle.zip -d /opt && \
    rm /tmp/gradle.zip /tmp/gradle.zip.sha256 && \
    rm -rf /opt/gradle-${GRADLE_VERSION}/src \
           /opt/gradle-${GRADLE_VERSION}/docs \
           /opt/gradle-${GRADLE_VERSION}/kotlin

FROM eclipse-temurin:25-jdk-alpine

ARG MAVEN_VERSION=3.9.16
ARG GRADLE_VERSION=9.6.1
ARG OPENSPEC_VERSION=1.8.0

LABEL org.opencontainers.image.title="opencode Development Environment" \
      org.opencontainers.image.description="Docker container with Java development tools and opencode CLI" \
      org.opencontainers.image.vendor="sfuhrm" \
      org.opencontainers.image.source="https://github.com/sfuhrm/opencode-docker" \
      org.opencontainers.image.licenses="Apache-2.0"

RUN apk add --no-cache bash curl ca-certificates unzip tar screen docker-cli docker-cli-compose nodejs npm git ripgrep fd jq fzf

RUN npm install -g --no-fund --no-audit @fission-ai/openspec@${OPENSPEC_VERSION} && \
    npm cache clean --force

COPY --from=builder /opt/apache-maven-${MAVEN_VERSION} /opt/apache-maven-${MAVEN_VERSION}
COPY --from=builder /opt/gradle-${GRADLE_VERSION} /opt/gradle-${GRADLE_VERSION}

RUN adduser -D user && \
    mkdir -p /workspace

COPY --from=builder /root/.opencode /home/user/.opencode

RUN chown -R user:user /home/user/.opencode && \
    chmod 755 /home/user/.opencode/bin/opencode && \
    ln -s /home/user/.opencode/bin/opencode /usr/local/bin/opencode

ENV PATH=/opt/apache-maven-${MAVEN_VERSION}/bin:/opt/gradle-${GRADLE_VERSION}/bin:/home/user/.opencode/bin:${PATH}

WORKDIR /workspace
USER user

VOLUME /workspace

CMD ["opencode"]
