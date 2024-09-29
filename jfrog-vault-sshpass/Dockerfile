# Use a base image
FROM alpine

# Install required packages
RUN apk update && \
    apk add --no-cache \
        curl \
        jq \
        openssl \
        openssh-client \
        sshpass \
        iproute2 \
        net-tools \
        bind-tools

# Set environment variables
ENV VAULT_VERSION=1.15.1
ENV JFROG_CLI_VERSION=2.52.9

# Install required packages and download Vault binary
RUN apk add --no-cache wget unzip \
    && wget -O vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
    && unzip vault.zip \
    && mv vault /usr/local/bin/ \
    && rm vault.zip

# Install JFrog CLI
RUN curl -fL https://releases.jfrog.io/artifactory/jfrog-cli/v2-jf/${JFROG_CLI_VERSION}/jfrog-cli-linux-amd64/jf -o /usr/local/bin/jf && \
    chmod +x /usr/local/bin/jf

# Set the default command to bash
CMD ["/bin/bash"]
