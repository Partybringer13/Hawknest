#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 09 - Chrony Time Synchronization"

MASTER="${CLUSTER_MASTER:-192.168.1.10}"

section "Installing Chrony"

if ! command -v chronyd >/dev/null 2>&1 && ! dpkg -s chrony >/dev/null 2>&1; then
    apt-get update
    apt-get install -y chrony
fi

section "Configuring Chrony"

cat >/etc/chrony/chrony.conf <<EOF
# HawkMox managed

server ${MASTER} iburst prefer

pool 2.debian.pool.ntp.org iburst
pool 0.debian.pool.ntp.org iburst
pool 1.debian.pool.ntp.org iburst
pool 3.debian.pool.ntp.org iburst

driftfile /var/lib/chrony/chrony.drift

makestep 1.0 3

rtcsync

logdir /var/log/chrony
EOF

systemctl enable chrony
systemctl restart chrony

sleep 5

section "Chrony Status"

chronyc sources || true

echo

chronyc tracking || true

success "Chrony configured."
