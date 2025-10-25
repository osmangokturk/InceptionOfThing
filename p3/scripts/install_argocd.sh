#!/usr/bin/env bash
set -euxo pipefail

# 0) small settle time for fresh cluster
sleep 5

# 1) namespace
sudo -u vagrant kubectl create namespace argocd
sudo -u vagrant kubectl create namespace dev

# 2) install Argo CD official bundle
sudo -u vagrant kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3) wait robustly: loop until all core deployments are Available (max ~8 min)
DEPS=("argocd-server" "argocd-repo-server" "argocd-applicationset-controller" "argocd-redis" "argocd-dex-server" "argocd-notifications-controller")
for i in $(seq 1 69); do
  ALL_READY=true
  for d in "${DEPS[@]}"; do
    AVAIL=$(sudo -u vagrant kubectl -n argocd get deploy "$d" -o jsonpath='{.status.availableReplicas}' || echo 0)
    if [ "${AVAIL:-0}" != "1" ]; then
      ALL_READY=false
    fi
  done
  if $ALL_READY; then
    echo "Argo CD core deployments are Available."
    break
  fi
  sleep 5
done

sudo -u vagrant kubectl apply -n argocd -f /vagrant/confs/argo-app.yaml

sudo -u vagrant kubectl apply -f /vagrant/confs/argocd-lb.yaml

echo argo pass:

sudo -u vagrant kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
echo