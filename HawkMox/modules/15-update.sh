#!/usr/bin/env bash
set -Eeuo pipefail

source "$(dirname "$0")/../lib/common.sh"

header "Module 15 - System Update"

section "Configuring Proxmox Repositories"

# Disable any Proxmox enterprise repositories (.list or .sources)
find /etc/apt/sources.list.d -maxdepth 1 \
    \( -name "*.list" -o -name "*.sources" \) | while read -r file; do
    if grep -qi "enterprise\.proxmox\.com" "$file"; then
        info "Disabling $(basename "$file")"
        mv -f "$file" "${file}.disabled"
    fi
done

# Remove any previous no-subscription definitions
rm -f /etc/apt/sources.list.d/pve-no-subscription.list
rm -f /etc/apt/sources.list.d/ceph-no-subscription.list

# Proxmox VE
cat >/etc/apt/sources.list.d/pve-no-subscription.list <<EOF
deb http://download.proxmox.com/debian/pve trixie pve-no-subscription
EOF

# Ceph
cat >/etc/apt/sources.list.d/ceph-no-subscription.list <<EOF
deb http://download.proxmox.com/debian/ceph-squid trixie no-subscription
EOF

pass "Configured Proxmox no-subscription repositories."

section "Updating Package Lists"

apt-get update

pass "Repositories updated."

section "Upgrading Packages"

DEBIAN_FRONTEND=noninteractive \
apt-get -y full-upgrade

pass "System upgraded."

section "Autoremove"

apt-get -y autoremove
apt-get clean

pass "Cleanup complete."

section "Versions"

echo "Kernel : $(uname -r)"
echo "PVE    : $(pveversion | head -1)"

section "Reboot Check"

if [[ -f /var/run/reboot-required ]]; then
    warn "A reboot is recommended."
else
    pass "No reboot required."
fi

pass "Module 15 completed successfully."
