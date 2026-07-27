FROM eclipse-temurin:25-jdk-alpine AS builder

ARG MAVEN_VERSION=3.9.16
ARG GRADLE_VERSION=9.6.1

RUN apk add --no-cache bash curl ca-certificates unzip tar && \
    curl -fsSL https://opencode.ai/install | bash && \
    curl -fsSL https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -xz -C /opt && \
    curl -fsSL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle.zip && \
    unzip -q /tmp/gradle.zip -d /opt && \
    rm /tmp/gradle.zip

FROM eclipse-temurin:25-jdk-alpine

ARG MAVEN_VERSION=3.9.16
ARG GRADLE_VERSION=9.6.1

RUN apk add --no-cache curl ca-certificates screen

COPY --from=builder /root/.opencode /root/.opencode
COPY --from=builder /opt/apache-maven-${MAVEN_VERSION} /opt/apache-maven-${MAVEN_VERSION}
COPY --from=builder /opt/gradle-${GRADLE_VERSION} /opt/gradle-${GRADLE_VERSION}

RUN chmod +x /root/.opencode/bin/opencode && \
    ln -sf /root/.opencode/bin/opencode /usr/local/bin/opencode && \
    ln -sf /opt/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn && \
    ln -sf /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle && \
    adduser -D user && \
    mkdir -p /workspace

WORKDIR /workspace
USER user

CMD ["opencode"]
