# Homelab GitOps (Phase 1)

This repo bootstraps a 3-node Kubernetes homelab (Beelink SER5) with:
- **CNI**: Cilium
- **LoadBalancer**: MetalLB
- **Ingress**: ingress-nginx
- **Storage**: Longhorn
- **Monitoring**: kube-prometheus-stack (Grafana/Prometheus/Alertmanager) with Slack alerts
- **GitOps**: Argo CD (App-of-Apps)

> Defaults assume LAN `192.168.68.0/24`, master at `192.168.68.91`, and a MetalLB pool `192.168.68.200-192.168.68.220`.
> Adjust files under `values/` and `cluster/` as needed.

## Quick Start

1) **Prep nodes** (run on each Ubuntu 24.04 node; idempotent):
```bash
sudo bash scripts/node_prep.sh
```

2) **Initialize control plane** (on master, edit `cluster/kubeadm-config.yaml` first):
```bash
sudo kubeadm init --config cluster/kubeadm-config.yaml
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

3) **Install Helm if needed**:
```bash
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

4) **Bootstrap cluster services + Argo CD + App-of-Apps** (from your workstation with kubectl context set to the cluster):
```bash
kubectl create ns argocd || true
bash scripts/cluster_bootstrap.sh
```

5) **Join workers** (on master):
```bash
kubeadm token create --print-join-command
```
Run the printed command on each worker node.

6) **Argo CD UI**: get the password and login
```bash
# service EXTERNAL-IP from MetalLB (type LoadBalancer)
kubectl -n argocd get svc argocd-server
# get initial password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

7) **Grafana** (when monitoring syncs): default user `admin`, password from values file
```bash
kubectl -n monitoring get svc kps-grafana
```

8) **Validate**:
- Nodes Ready
- MetalLB assigns EXTERNAL-IP
- Argo CD syncs Applications
- Grafana reachable
- Slack alerts firing (when a pod is disrupted)

## Structure

```
homelab-gitops/
├─ README.md
├─ apps/
│  └─ applications/
│     ├─ kustomization.yaml
│     ├─ argocd.yaml
│     ├─ cilium.yaml
│     ├─ metallb.yaml
│     ├─ ingress-nginx.yaml
│     ├─ longhorn.yaml
│     └─ monitoring.yaml
├─ cluster/
│  └─ kubeadm-config.yaml
├─ scripts/
│  ├─ node_prep.sh
│  └─ cluster_bootstrap.sh
└─ values/
   ├─ monitoring/values-kps.yaml
   ├─ metallb/ipaddresspool.yaml
   ├─ ingress-nginx/values.yaml
   └─ longhorn/values.yaml
```

## Notes
- Values are inlined in the Argo CD Applications for portability; also duplicated under `values/` for easy editing.
- Replace `YOUR_SLACK_WEBHOOK_URL` and `#homelab-alerts` in `values/monitoring/values-kps.yaml` and `apps/applications/monitoring.yaml`.
- To add apps later, create a new Application YAML under `apps/applications/` and add it to `kustomization.yaml`.
