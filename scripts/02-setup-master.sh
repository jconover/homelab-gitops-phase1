#!/usr/bin/env bash
set -euo pipefail

# Initialize control plane on master
sudo kubeadm init --config cluster/kubeadm-config.yaml
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Helm if needed
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Bootstrap cluster services + Argo CD + App-of-Apps
kubectl create ns argocd || true
bash scripts/03-cluster_bootstrap.sh

echo "[OK] Control plane initialized and cluster services installed."
echo "Wait for Argo CD to sync Applications. Then manage everything via the Argo UI."

# join workers
kubeadm token create --print-join-command

echo "[OK] Workers joined. Now manage everything via the Argo UI."
