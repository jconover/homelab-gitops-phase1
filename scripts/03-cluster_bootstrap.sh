#!/usr/bin/env bash
set -euo pipefail

# Install Helm if needed
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Ensure Helm repos are present
helm repo add argo https://argoproj.github.io/argo-helm || true
helm repo add cilium https://helm.cilium.io/ || true
helm repo add metallb https://metallb.github.io/metallb || true
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx || true
helm repo add longhorn https://charts.longhorn.io || true
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo add grafana https://grafana.github.io/helm-charts || true
helm repo update

# 1) Install Argo CD via Helm (one-time)
kubectl create ns argocd || true
helm upgrade --install argocd argo/argo-cd -n argocd   --set server.service.type=LoadBalancer

# 2) Apply App-of-Apps root (Kustomize of Application CRDs)
kubectl apply -k apps/applications

echo "[OK] Argo CD installed and App-of-Apps applied."
echo "Wait for Argo CD to sync Applications. Then manage everything via the Argo UI."
