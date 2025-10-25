#!/usr/bin/env bash

# To print more info to the error. 
set -euxo pipefail

#Define Variables with positional names 
SERVER_IP="${1:-192.168.56.110}"
NODE_IP="${2:-192.168.56.111}"
CLUSTER_TOKEN="${3:-k3s-default-token}"

curl -sfL https://get.k3s.io |
  sudo K3S_URL="https://${SERVER_IP}:6443" \
    K3S_TOKEN="${CLUSTER_TOKEN}" \
    INSTALL_K3S_EXEC="\
    agent \
    --node-ip=${NODE_IP} \
    --node-external-ip=${NODE_IP}" sh -
