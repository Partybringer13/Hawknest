#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 05 - System Configuration"

############################################################
section "Enable Services"

SERVICES=(
    pve-cluster
    pvedaemon
    pveproxy
    pvestatd
    chrony
)

for SERVICE in "${SERVICES[@]}"
do
    systemctl enable "${SERVICE}" >/dev/null
    systemctl restart "${SERVICE}" >/dev/null
    success "${SERVICE} enabled."
done

############################################################
section "ZFS"

zpool set autoreplace=on "${POOL_NAME}" || true
zpool set autotrim="${AUTOTRIM}" "${POOL_NAME}" || true

success "Pool properties configured."

############################################################
section "Directories"

ensure_storage_dirs

success "Storage directories verified."

############################################################
section "Finished"

success "Module 05 completed successfully."
