#!/usr/bin/env bash
set -euxo pipefail

SERVER_IP="${1:-192.168.56.110}"
CLUSTER_TOKEN="${2:-k3s-default-token}"

curl -sfL https://get.k3s.io | sudo \
  K3S_TOKEN="${CLUSTER_TOKEN}" \
  INSTALL_K3S_EXEC="server \
    --node-ip=${SERVER_IP} \
    --node-external-ip=${SERVER_IP} \
    --tls-san=${SERVER_IP} \
    --write-kubeconfig-mode=644" \
  sh -

sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config

sudo -u vagrant sed -i "s/127.0.0.1/${SERVER_IP}/g" /home/vagrant/.kube/config
