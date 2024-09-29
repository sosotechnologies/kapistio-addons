#!/bin/bash

# Register the GitLab Runner
gitlab-runner register \
    --non-interactive \
    --url "https://gitlab.com/" \
    --registration-token "GR1348941Fhmyg9KTow453ifB_Lkq" \
    --executor "kubernetes" \
    --name "kubernetes" \
    --run-untagged="true" \
    --tag-list "kubernetes" \
    --tls-ca-file="/etc/gitlab-runner/cacerts.crt" \
    --kubernetes-cpu-limit="4800m" \
    --kubernetes-cpu-request="390m" \
    --kubernetes-memory-limit="9Gi" \
    --kubernetes-memory-request="637Mi" \
    --kubernetes-helper-cpu-limit="2500m" \
    --kubernetes-helper-image="ubuntu:22.04" \
    --kubernetes-helper-cpu-request="41m" \
    --kubernetes-helper-memory-limit="800Mi" \
    --kubernetes-helper-memory-request="74Mi" \
    --kubernetes-image="alpine:latest" \
    --kubernetes-namespace="gitlab-runner" \
    --kubernetes-pull-policy="always" \
    --kubernetes-privileged="false" \
    --kubernetes-serviceaccount="gitlab-admin" \
    --kubernetes-service-cpu-limit="1400m" \
    --kubernetes-service-cpu-request="21m" \
    --kubernetes-service-memory-limit="310Mi" \
    --kubernetes-service-memory-request="4Mi" \
    --locked="false" \
    --maximum-timeouts="1200" \
    --non-interactive \
    --run-untagged="true" \
    --tag-list="kubernetes" 

# Print the content of the config.toml file
cat /etc/gitlab-runner/config.toml

# Start the GitLab Runner
exec /usr/bin/gitlab-runner run


# #!/bin/bash

# # GitLab Runner registration script

# # Set environment variables
# export GIT_SSL_CAPATH="/etc/ssl/runner-cacert/cacert.crt"
# export PIP_CERT="/etc/ssl/runner-cacert/cacert.crt"
# export NODE_EXTRA_CA_CERT="/etc/ssl/runner-cacert/cacert.crt"
# export cafile="/etcssl/runner-cacert/cacert.crt"
# export SSL_CERT_FILE="/etc/ssl/runner-cacert/cacert.crt"

# # Register the GitLab Runner
# gitlab-runner register --non-interactive \
#     --url "https://gitlab.com/" \
#     --registration-token "GR1348941Fhmyg9KTow453ifB_Lkq" \
#     --executor "kubernetes" \
#     --name "kubernetes-sunday" \
#     --run-untagged="true" \
#     --tag-list "kubernetes" \
#     --tls-ca-file="/etc/ssl/runner-cacert/cacert.crt" \
#     --kubernetes-image-pull-secret="regret" \
#     --kubernetes-cpu-limit="4800m" \
#     --kubernetes-cpu-request="390m" \
#     --kubernetes-memory-limit="9Gi" \
#     --kubernetes-memory-request="637Mi" \
#     --kubernetes-helper-cpu-limit="2500m" \
#     --kubernetes-helper-image="cafanwii/helper:1.0.0" \
#     --kubernetes-helper-cpu-request="41m" \
#     --kubernetes-helper-memory-limit="800Mi" \
#     --kubernetes-helper-memory-request="74Mi" \
#     --kubernetes-namespace="gitlab-runner" \
#     --kubernetes-pull-policy="always" \
#     --kubernetes-privileged="false" \
#     --kubernetes-serviceaccount="gitlab-admin " \
#     --kubernetes-service-cpu-limit="1400m" \
#     --kubernetes-service-cpu-request="21m" \
#     --kubernetes-service-memory-limit="310Mi" \
#     --kubernetes-service-memory-request="4Mi" \
#     --locked="false" \
#     --maximum-timeouts="1200"

# Add a volume to the GitLab Runner config
echo '[[runners.kubernetes.volumes.config_map]]' >> /etc/gitlab-runner/config.toml
echo 'name = "cacert"' >> /etc/gitlab-runner/config.toml
echo 'mount_path = "/etc/ssl/runner-cacert"' >> /etc/gitlab-runner/config.toml
