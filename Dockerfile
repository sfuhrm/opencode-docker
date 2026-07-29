FROM eclipse-temurin:25-jdk-alpine AS builder

ARG MAVEN_VERSION=3.9.16
ARG GRADLE_VERSION=9.6.1

RUN apk add --no-cache bash curl ca-certificates unzip tar && \
    curl -fsSL https://opencode.ai/install | bash && \
    curl -fsSL https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -o /tmp/maven.tar.gz && \
    curl -fsSL https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512 -o /tmp/maven.tar.gz.sha512 && \
    cd /tmp && sha512sum -c maven.tar.gz.sha512 && \
    tar -xz -C /opt -f /tmp/maven.tar.gz && \
    curl -fsSL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle.zip && \
    curl -fsSL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip.sha256 -o /tmp/gradle.zip.sha256 && \
    cd /tmp && sha256sum -c gradle.zip.sha256 && \
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

LABEL org.opencontainers.image.title="opencode Development Environment" \
      org.opencontainers.image.description="Docker container with Java development tools and opencode CLI" \
      org.opencontainers.image.vendor="sfuhrm" \
      org.opencontainers.image.source="https://github.com/sfuhrm/opencode-docker" \
      org.opencontainers.image.licenses="Apache-2.0"

RUN apk add --no-cache bash curl ca-certificates

COPY --from=builder /root/.opencode /root/.opencode
COPY --from=builder /opt/apache-maven-${MAVEN_VERSION} /opt/apache-maven-${MAVEN_VERSION}
COPY --from=builder /opt/gradle-${GRADLE_VERSION} /opt/gradle-${GRADLE_VERSION}

ENV PATH=/opt/apache-maven-${MAVEN_VERSION}/bin:/opt/gradle-${GRADLE_VERSION}/bin:${PATH}

RUN cp /root/.opencode/bin/opencode /usr/local/bin/opencode && \
    chmod +x /usr/local/bin/opencode && \
    chmod -R a+rX /root/.opencode && \
    adduser -D user && \
    mkdir -p /workspace

WORKDIR /workspace
USER user

VOLUME /workspace

CMD ["opencode"]
