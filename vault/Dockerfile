# Use an official base image (Alpine Linux in this example)
FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y curl jq unzip sshpass openssh-client

# Set environment variables for Vault
ENV VAULT_VERSION=1.15.1
ENV VAULT_ADDR=http://vault.sosotech.io:8200

# Install required packages and download Vault binary
RUN apt-get install -y wget \
    && wget -O vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
    && unzip vault.zip \
    && mv vault /usr/local/bin/ \
    && rm vault.zip


RUN apt-get clean

# Expose the Vault server port
EXPOSE 8200

# Set the entrypoint for the container
CMD ["vault", "server", "-config=/etc/vault/config.hcl"]

# CMD ["/bin/bash"]


# https://releases.hashicorp.com/vault/
# https://releases.hashicorp.com/vault/1.15.1/vault_1.15.1_linux_amd64.zip