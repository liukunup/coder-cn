FROM ghcr.io/coder/coder:latest

USER root

# Use tls certificate
# COPY cert/*.crt /usr/local/share/ca-certificates/

# Install package
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk update \
    && apk add curl unzip ca-certificates \
    && rm -rf /var/cache/apk/* \
    && update-ca-certificates

# Define the target CPU architecture for multi-platform build.
# Defaults to 'amd64' (x86-64). Can be overridden at build time with --build-arg.
ARG ARCH=amd64

# Define a proxy URL for GitHub to accelerate source code downloading in regions
# where GitHub access might be slow or restricted.
# This is particularly useful for cloning repositories or downloading releases.
ARG GITHUB_PROXY=

# Create directory for the Terraform CLI (and assets)
RUN mkdir -p /opt/terraform

# Terraform is already included in the official Coder image.
# See https://github.com/coder/coder/blob/main/scripts/Dockerfile.base#L15
# If you need to install a different version of Terraform, you can do so here.
# The below step is optional if you wish to keep the existing version.
# See https://github.com/coder/coder/blob/main/provisioner/terraform/install.go#L23-L24
# for supported Terraform versions.
ARG TERRAFORM_VERSION=1.13.4
RUN apk update \
    && curl -LOs https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip \
    && unzip -o terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip \
    && mv terraform /opt/terraform \
    && rm terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip
ENV PATH=/opt/terraform:${PATH}

# Additionally, a Terraform mirror needs to be configured
# to download the Terraform providers used in Coder templates.
# There are two options:

# Option 1) Use a filesystem mirror.
#  We can seed this at build-time or by mounting a volume to
#  /opt/terraform/plugins in the container.
#  https://developer.hashicorp.com/terraform/cli/config/config-file#filesystem_mirror
#  Be sure to add all the providers you use in your templates to /opt/terraform/plugins

RUN mkdir -p /home/coder/.terraform.d/plugins/registry.terraform.io
ADD filesystem-mirror.tfrc /home/coder/.terraformrc

# Optionally, we can "seed" the filesystem mirror with common providers.
# Comment out lines 40-49 if you plan on only using a volume or network mirror:
WORKDIR /home/coder/.terraform.d/plugins/registry.terraform.io

ARG CODER_PROVIDER_VERSION=2.12.0
RUN echo "Adding coder/coder v${CODER_PROVIDER_VERSION}" \
    && mkdir -p coder/coder && cd coder/coder \
    && curl -LOs ${GITHUB_PROXY}https://github.com/coder/terraform-provider-coder/releases/download/v${CODER_PROVIDER_VERSION}/terraform-provider-coder_${CODER_PROVIDER_VERSION}_linux_${ARCH}.zip

ARG DOCKER_PROVIDER_VERSION=3.8.0
RUN echo "Adding kreuzwerker/docker v${DOCKER_PROVIDER_VERSION}" \
    && mkdir -p kreuzwerker/docker && cd kreuzwerker/docker \
    && curl -LOs ${GITHUB_PROXY}https://github.com/kreuzwerker/terraform-provider-docker/releases/download/v${DOCKER_PROVIDER_VERSION}/terraform-provider-docker_${DOCKER_PROVIDER_VERSION}_linux_${ARCH}.zip

ARG KUBERNETES_PROVIDER_VERSION=2.38.0
RUN echo "Adding kubernetes/kubernetes v${KUBERNETES_PROVIDER_VERSION}" \
    && mkdir -p hashicorp/kubernetes && cd hashicorp/kubernetes \
    && curl -LOs https://releases.hashicorp.com/terraform-provider-kubernetes/${KUBERNETES_PROVIDER_VERSION}/terraform-provider-kubernetes_${KUBERNETES_PROVIDER_VERSION}_linux_${ARCH}.zip

ARG AWS_PROVIDER_VERSION=6.18.0
RUN echo "Adding aws/aws v${AWS_PROVIDER_VERSION}" \
    && mkdir -p aws/aws && cd aws/aws \
    && curl -LOs https://releases.hashicorp.com/terraform-provider-aws/${AWS_PROVIDER_VERSION}/terraform-provider-aws_${AWS_PROVIDER_VERSION}_linux_${ARCH}.zip

ARG HASHICORP_LOCAL_VERSION=2.5.3
RUN echo "Adding hashicorp/local v${HASHICORP_LOCAL_VERSION}" \
    && mkdir -p hashicorp/local && cd hashicorp/local \
    && curl -LOs https://releases.hashicorp.com/terraform-provider-local/${HASHICORP_LOCAL_VERSION}/terraform-provider-local_${HASHICORP_LOCAL_VERSION}_linux_${ARCH}.zip

ARG HASHICORP_NULL_VERSION=3.2.4
RUN echo  "Adding hashicorp/null v${HASHICORP_NULL_VERSION}" \
    && mkdir -p hashicorp/null && cd hashicorp/null \
    && curl -LOs https://releases.hashicorp.com/terraform-provider-null/${HASHICORP_NULL_VERSION}/terraform-provider-null_${HASHICORP_NULL_VERSION}_linux_${ARCH}.zip

ARG PVE_PROVIDER_VERSION=3.0.2-rc05
RUN echo  "Adding telmate/terraform-provider-proxmox v${PVE_PROVIDER_VERSION}" \
    && mkdir -p telmate/proxmox && cd telmate/proxmox \
    && curl -LOs ${GITHUB_PROXY}https://github.com/Telmate/terraform-provider-proxmox/releases/download/v${PVE_PROVIDER_VERSION}/terraform-provider-proxmox_${PVE_PROVIDER_VERSION}_linux_${ARCH}.zip

RUN chown -R coder:coder /home/coder/.terraform*
WORKDIR /home/coder

# Option 2) Use a network mirror.
#  https://developer.hashicorp.com/terraform/cli/config/config-file#network_mirror
#  Be sure uncomment line 60 and edit network-mirror-example.tfrc to
#  specify the HTTPS base URL of your mirror.

# ADD network-mirror-example.tfrc /home/coder/.terraformrc

USER coder

# Use the .terraformrc file to inform Terraform of the locally installed providers.
ENV TF_CLI_CONFIG_FILE=/home/coder/.terraformrc
