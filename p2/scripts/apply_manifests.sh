#!/usr/bin/env bash
set -euxo pipefail
# Wait for Traefik to be ready (Ingress controller)
# sudo kubectl -n kube-system rollout status deploy/traefik --timeout=120s || true
# Apply apps and ingress
sudo kubectl apply -f /vagrant/confs/apps.yaml
sudo kubectl apply -f /vagrant/confs/ingress.yaml
# Show what we deployed
sudo kubectl get deploy,svc,ingress -o wide