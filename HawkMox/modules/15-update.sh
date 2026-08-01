#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 15 - System Update"

############################################################
section "Configure Proxmox Repositories"

rm -f /etc/apt/sources.list.d/pve-enterprise.list
rm -f /etc/apt/sources.list.d/ceph.list

rm -f /etc/apt/sources.list.d/pve-enterprise.sources
rm -f /etc/apt/sources.list.d/ceph.sources

cat >/etc/apt/sources.list.d/pve-no-subscription.list <<EOF
deb http://download.proxmox.com/debian/pve trixie pve-no-subscription
EOF

cat >/etc/apt/sources.list.d/ceph-no-subscription.list <<EOF
deb http://download.proxmox.com/debian/ceph-squid trixie no-subscription
EOF

pass "Configured Proxmox repositories."

############################################################
section "Updating Package Lists"

apt update

############################################################
section "Upgrading"

DEBIAN_FRONTEND=noninteractive \
apt -y full-upgrade

############################################################
section "Autoremove"

apt -y autoremove

apt clean

############################################################

pass "Module 15 completed successfully."
