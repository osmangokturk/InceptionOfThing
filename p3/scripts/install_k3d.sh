#!/usr/bin/env bash
set -euxo pipefail

# --- Install Docker ---
sudo apt update -y
sudo mkdir -p /etc/apt/keyrings
sudo apt install gnupg vim git ca-certificates curl lsb-release -y
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian $(lsb_release -cs) stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker vagrant

# --- Install K3d ---
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# --- Install kubectl ---
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# --- Create cluster ---
sudo -u vagrant k3d cluster create mycluster \
  --api-port 6445 \
  --servers 1 \
  --agents 1 \
  --port "8888:8888@loadbalancer" \
  --port "8080:8080@loadbalancer"

# configure kubectl
sudo -u vagrant k3d kubeconfig get mycluster >/home/vagrant/.kube/config

