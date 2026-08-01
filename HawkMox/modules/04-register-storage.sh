#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${PROJECT_ROOT}/lib/common.sh"

header "Module 04 - Register Proxmox Storage"

############################################################

section "Verifying Datasets"

dataset_exists "${POOL_NAME}/${VM_DATASET}" \
    || die "Dataset '${VM_DATASET}' missing."

dataset_exists "${POOL_NAME}/${FILE_DATASET}" \
    || die "Dataset '${FILE_DATASET}' missing."

success "Datasets verified."

############################################################

section "Registering Proxmox Storage"

register_zfs_storage

register_dir_storage

############################################################

section "Current Storage"

cat /etc/pve/storage.cfg

echo

pvesm status

echo

success "Module 04 completed successfully."
