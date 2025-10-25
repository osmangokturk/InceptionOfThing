#!/usr/bin/env bash
set -euxo pipefail

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y curl

sudo -u vagrant mkdir -p /home/vagrant/.kube

