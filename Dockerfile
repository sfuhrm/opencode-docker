FROM debian:13

ENV DEBIAN_FRONTEND=noninteractive
ARG MAVEN_VERSION=3.9.16
ARG GRADLE_VERSION=9.6.1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        unzip \
        screen \
        openjdk-25-jdk 2>/dev/null || \
        (apt-get install -y --no-install-recommends openjdk-17-jdk || apt-get install -y --no-install-recommends openjdk-21-jdk || true) && \
    curl -fsSL https://opencode.ai/install | bash && \
    ln -sf /root/.opencode/bin/opencode /usr/local/bin/opencode && \
    curl -fsSL https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -xz -C /opt && \
    ln -sf /opt/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn && \
    curl -fsSL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle.zip && \
    unzip -q /tmp/gradle.zip -d /opt && \
    rm /tmp/gradle.zip && \
    ln -sf /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle && \
    useradd -m user && \
    mkdir -p /workspace && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
USER user

CMD ["opencode"]
