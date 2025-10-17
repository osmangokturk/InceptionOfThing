#!/bin/bash

# K3s Worker Node Setup Script
set -e  # Exit on any error

echo "=== Setting up K3s Worker Node ==="

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
if [ -f /usr/local/bin/k3s-agent-uninstall.sh ]; then
    sudo /usr/local/bin/k3s-agent-uninstall.sh
fi

# Wait for control plane to be ready and get token
echo "Waiting for control plane token..."
until [ -f /vagrant/k3s-token ]; do
    echo "Waiting for token file from control plane..."
    sleep 10
done

K3S_TOKEN=$(cat /vagrant/k3s-token)
SERVER_IP="192.168.56.110"

echo "Installing K3s agent joining to ${SERVER_IP}"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent \
    --server https://${SERVER_IP}:6443 \
    --node-ip 192.168.56.111 \
    --token ${K3S_TOKEN} \
    --flannel-iface eth1" sh -

echo "=== Worker Node Setup Complete ==="
echo "Node should now be joining the cluster..."