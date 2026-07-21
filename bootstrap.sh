infra_user=infra
eth_device=enP7s7
eth_addresses="[10.255.0.50/24]"
eth_nameservers="[1.1.1.1, 1.0.0.1, 8.8.8.8, 8.8.4.4]"
eth_router="10.255.0.1"
tailscale_server=https://headscale.chiiiirs.com

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
      addresses: $eth_addresses
      routes:
        - to: default
          via: $eth_router
      nameservers:
        addresses: $eth_nameservers
EOF
netplan apply

# Update the system.
apt-get update
apt-get dist-upgrade -y

# Install basic utilities.
apt-get install -y \
  iputils-ping \
  bind9-dnsutils \
  tmux \
  vim-nox

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
