#!/bin/bash

# K3s Control Plane Setup Script
set -e  # Exit on any error

echo "=== Setting up K3s Control Plane ==="

# System preparation
echo "Updating system and installing dependencies..."
sudo dnf update -y
sudo dnf install -y curl net-tools

# Security configuration (for lab environment only!)
echo "Configuring system security settings..."
sudo systemctl disable firewalld --now
sudo setenforce 0
sudo sed -i 's/SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

# Cleanup any existing K3s installation
echo "Cleaning up any existing K3s installation..."
if [ -f /usr/local/bin/k3s-uninstall.sh ]; then
    sudo /usr/local/bin/k3s-uninstall.sh
fi

# Kill any process using port 6443
echo "Ensuring port 6443 is free..."
sudo pkill -f "k3s server" || true
sudo ss -tulpn | grep 6443 && sudo kill $(sudo ss -tulpn | grep 6443 | awk '{print $7}' | cut -d= -f2 | cut -d, -f1) || true

# Generate a secure token (or use a predefined one)
K3S_TOKEN="k3s-cluster-token-$(date +%s | tail -c 4)"
echo "${K3S_TOKEN}" | sudo tee /vagrant/k3s-token > /dev/null
sudo chmod 644 /vagrant/k3s-token

echo "Installing K3s control plane with token: ${K3S_TOKEN}"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
    --node-ip 192.168.56.110 \
    --write-kubeconfig-mode 0644 \
    --token ${K3S_TOKEN} \
    --tls-san 192.168.56.110 \
    --flannel-iface eth1" sh -

# Wait for K3s to be ready. use the binary as the KUBECONFIG ıs not yet ready.
echo "Waiting for K3s to be ready..."
until sudo /usr/local/bin/k3s kubectl get nodes >/dev/null 2>&1; do
    echo "Waiting for control plane to be ready..."
    sleep 5
done

# Make kubeconfig accessible
echo "Setting up kubectl access..."
sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/k3s-config 
sudo chmod 644 /vagrant/k3s-config
sed -i 's/127.0.0.1/192.168.56.110/g' /vagrant/k3s-config

# Set up aliases and environment
echo "Configuring user environment..."
echo 'alias k="kubectl"' >> /home/vagrant/.bashrc
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /home/vagrant/.bashrc

# Display cluster info
echo "=== Control Plane Setup Complete ==="
kubectl get nodes
echo "Kubeconfig copied to: /vagrant/k3s-config"
echo "Token saved to: /vagrant/k3s-token"