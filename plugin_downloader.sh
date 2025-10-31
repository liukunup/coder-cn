#!/bin/bash

set -euo pipefail

# Define the target CPU architecture for multi-platform build.
# Defaults to 'amd64' (x86-64).
ARCH=${1:-amd64}

# Define a proxy URL for GitHub to accelerate downloading in regions
# where GitHub access might be slow or restricted.
GITHUB_PROXY=${2:-}

download() {
    local namespace=$1
    local name=$2
    local version=$3
    local url=$4

    echo "Adding ${namespace}/${name} v${version}" \
    && mkdir -p "${namespace}/${name}" && cd "${namespace}/${name}" \
    && curl -fLOs "${url}"
}

CODER_PROVIDER_VERSION=2.12.0
download "coder" "coder" "${CODER_PROVIDER_VERSION}" \
    "${GITHUB_PROXY}https://github.com/coder/terraform-provider-coder/releases/download/v${CODER_PROVIDER_VERSION}/terraform-provider-coder_${CODER_PROVIDER_VERSION}_linux_${ARCH}.zip"

DOCKER_PROVIDER_VERSION=3.8.0
download "kreuzwerker" "docker" "${DOCKER_PROVIDER_VERSION}" \
    "${GITHUB_PROXY}https://github.com/kreuzwerker/terraform-provider-docker/releases/download/v${DOCKER_PROVIDER_VERSION}/terraform-provider-docker_${DOCKER_PROVIDER_VERSION}_linux_${ARCH}.zip"

KUBERNETES_PROVIDER_VERSION=2.38.0
download "hashicorp" "kubernetes" "${KUBERNETES_PROVIDER_VERSION}" \
    "https://releases.hashicorp.com/terraform-provider-kubernetes/${KUBERNETES_PROVIDER_VERSION}/terraform-provider-kubernetes_${KUBERNETES_PROVIDER_VERSION}_linux_${ARCH}.zip"

AWS_PROVIDER_VERSION=6.18.0
download "aws" "aws" "${AWS_PROVIDER_VERSION}" \
    "https://releases.hashicorp.com/terraform-provider-aws/${AWS_PROVIDER_VERSION}/terraform-provider-aws_${AWS_PROVIDER_VERSION}_linux_${ARCH}.zip"

ALICLOUD_PROVIDER_VERSION=1.261.0
download "alicloud" "alicloud" "${ALICLOUD_PROVIDER_VERSION}" \
    "https://releases.hashicorp.com/terraform-provider-alicloud/${ALICLOUD_PROVIDER_VERSION}/terraform-provider-alicloud_${ALICLOUD_PROVIDER_VERSION}_linux_${ARCH}.zip"

HASHICORP_LOCAL_VERSION=2.5.3
download "hashicorp" "local" "${HASHICORP_LOCAL_VERSION}" \
    "https://releases.hashicorp.com/terraform-provider-local/${HASHICORP_LOCAL_VERSION}/terraform-provider-local_${HASHICORP_LOCAL_VERSION}_linux_${ARCH}.zip"

HASHICORP_NULL_VERSION=3.2.4
download "hashicorp" "null" "${HASHICORP_NULL_VERSION}" \
    "https://releases.hashicorp.com/terraform-provider-null/${HASHICORP_NULL_VERSION}/terraform-provider-null_${HASHICORP_NULL_VERSION}_linux_${ARCH}.zip"

HASHICORP_HTTP_VERSION=3.5.0
download "hashicorp" "http" "${HASHICORP_HTTP_VERSION}" \
    "https://releases.hashicorp.com/terraform-provider-http/${HASHICORP_HTTP_VERSION}/terraform-provider-http_${HASHICORP_HTTP_VERSION}_linux_${ARCH}.zip"

PVE_PROVIDER_VERSION=3.0.2-rc05
download "telmate" "proxmox" "${PVE_PROVIDER_VERSION}" \
    "${GITHUB_PROXY}https://github.com/Telmate/terraform-provider-proxmox/releases/download/v${PVE_PROVIDER_VERSION}/terraform-provider-proxmox_${PVE_PROVIDER_VERSION}_linux_${ARCH}.zip"

echo "🎉 Plugins download completed successfully!"
