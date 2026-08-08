FROM eclipse-temurin:25-jdk-alpine AS builder

ARG MAVEN_VERSION=3.9.16
ARG GRADLE_VERSION=9.6.1
ARG OPENCODE_VERSION=1.18.15

RUN set -euo pipefail && \
    apk add --no-cache bash curl ca-certificates unzip tar && \
    curl -fsSL https://opencode.ai/install | bash -s -- --version ${OPENCODE_VERSION} --no-modify-path && \
    curl -fsSL https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -o /tmp/maven.tar.gz && \
    curl -fsSL https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512 -o /tmp/maven.tar.gz.sha512 && \
    expected_maven="$(tr -d '[:space:]' < /tmp/maven.tar.gz.sha512)" && \
    actual_maven="$(sha512sum /tmp/maven.tar.gz | awk '{print $1}')" && \
    [ "$expected_maven" = "$actual_maven" ] && \
    tar -xz -C /opt -f /tmp/maven.tar.gz && \
    curl -fsSL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle.zip && \
    curl -fsSL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip.sha256 -o /tmp/gradle.zip.sha256 && \
    expected_gradle="$(tr -d '[:space:]' < /tmp/gradle.zip.sha256)" && \
    actual_gradle="$(sha256sum /tmp/gradle.zip | awk '{print $1}')" && \
    [ "$expected_gradle" = "$actual_gradle" ] && \
    unzip -q /tmp/gradle.zip -d /opt && \
    rm /tmp/maven.tar.gz /tmp/maven.tar.gz.sha512 /tmp/gradle.zip /tmp/gradle.zip.sha256 && \
    rm -rf /opt/apache-maven-${MAVEN_VERSION}/src \
           /opt/apache-maven-${MAVEN_VERSION}/docs \
           /opt/gradle-${GRADLE_VERSION}/src \
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

RUN apk add --no-cache bash curl ca-certificates unzip tar screen docker-cli docker-cli-compose nodejs npm

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
