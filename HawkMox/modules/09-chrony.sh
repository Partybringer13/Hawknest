#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 09 - Chrony"

############################################################
section "Configuration"

cat >/etc/chrony/chrony.conf <<EOF
pool ${CLUSTER_MASTER_IP} iburst
makestep 1.0 3

driftfile /var/lib/chrony/chrony.drift
rtcsync

allow 192.168.0.0/16

logdir /var/log/chrony
EOF

success "chrony.conf installed."

############################################################
section "Restart"

systemctl enable chrony
systemctl restart chrony

sleep 5

############################################################
section "Status"

chronyc tracking

echo

chronyc sources

############################################################

success "Module 09 completed successfully."
