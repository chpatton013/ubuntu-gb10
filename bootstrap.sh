#!/bin/bash --norc
set -euo pipefail

infra_user=infra
eth_device=enP7s7
eth_address_cidr="$1"
eth_router_ip="$2"

# Give passwordless sudo access to the infra user.
echo "$infra_user ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$infra_user"

# Give this machine a static IP address on LAN.
cat <<EOF >/etc/netplan/50-cloud-init.yaml
network:
  version: 2
  ethernets:
    $eth_device:
      dhcp4: false
      dhcp6: false
      addresses:
      - $eth_address_cidr
      routes:
        - to: default
          via: $eth_router_ip
      nameservers:
        addresses:
          - 1.1.1.1 # Cloudflare
          - 1.0.0.1
          - 8.8.8.8 # Google
          - 8.8.4.4
EOF
netplan apply

# Update the system.
apt-get update
apt-get dist-upgrade -y

# Install basic utilities.
apt-get install -y \
  bind9-dnsutils \
  iputils-ping \
  tmux \
  vim-tiny
