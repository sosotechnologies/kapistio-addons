FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and GitLab Runner
RUN apt-get update && \
    apt-get install -y curl openssh-client && \
    curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash && \
    apt-get install -y gitlab-runner && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install GitLab Runner
RUN curl -LJO "https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_amd64.deb" && \
    dpkg -i gitlab-runner_amd64.deb && \
    rm gitlab-runner_amd64.deb

# Install dumb-init
RUN curl -Lo /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 && \
    chmod +x /usr/bin/dumb-init

# Register GitLab Runner using the custom registration script
RUN gitlab-runner register --non-interactive \
        --url "https://gitlab.com/" \
        --token "glrt-C6G2HxU6uiHJMZ6txzWk" \
        --executor "shell" \
        --name "k8s-dev-master" \
        --tag-list "k8s-dev-master" \
        --run-untagged="true" \
        --locked="false" \
        --access-level="not_protected" 
        
# # Create a directory for the SSL certificate
# RUN mkdir -p /etc/ssl/runner-cacert
# # Copy the SSL certificate to the correct location
# COPY cacert.crt /etc/ssl/runner-cacert/cacert.crt

# # Copy the GitLab Runner configuration file to its final destination
# COPY /etc/gitlab-runner/util/config.toml /etc/gitlab-runner/config.toml

# # Copy the SSL certificate to the GitLab Runner configuration
# COPY /etc/ssl/runner-cacert/cacert.crt /etc/gitlab-runner/config.toml

# Extract the token from the configuration and save it to a new file
RUN awk '/token/ {print $3}' /etc/gitlab-runner/config.toml

# Entrypoint
ENTRYPOINT ["gitlab-runner"]
CMD ["run", "--user=root", "--working-directory=/home/gitlab-runner"]
