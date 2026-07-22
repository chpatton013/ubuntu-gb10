#!/bin/bash --norc
set -euo pipefail

infra_user=infra
tailscale_server=https://headscale.chiiiirs.com

# Install and configure tailscale.
curl -fsSL https://tailscale.com/install.sh | sh
# TODO: add `--ssh --accept-risk=lose-ssh` after setting up control plane permissions
tailscale set \
  --accept-dns \
  --accept-routes \
  --auto-update \
  --exit-node=aws-exit \
  --exit-node-allow-lan-access \
  --operator="$infra_user" \
  --report-posture
tailscale up "--login-server=$tailscale_server"
systemctl enable --now tailscaled
