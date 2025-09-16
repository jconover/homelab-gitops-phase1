#!/usr/bin/env bash
set -euo pipefail

# Initialize control plane on master
sudo kubeadm init --config cluster/kubeadm-config.yaml
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "[OK] Control plane initialized and cluster services installed."

# join workers
kubeadm token create --print-join-command

echo "[OK] Workers joined. Now manage everything via the Argo UI."
