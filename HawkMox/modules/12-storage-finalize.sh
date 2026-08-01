#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 12 - Storage Finalization"

############################################################
section "Removing obsolete storage definitions"

remove_storage local-lvm

remove_storage local

pass "Legacy storage definitions removed."

############################################################
section "Verifying HawkMox storage"

storage_exists "${ZFS_STORAGE_ID}" \
    || die "${ZFS_STORAGE_ID} missing."

storage_exists "${DIR_STORAGE_ID}" \
    || die "${DIR_STORAGE_ID} missing."

pass "${ZFS_STORAGE_ID} verified."

pass "${DIR_STORAGE_ID} verified."

############################################################
section "Current Configuration"

cat /etc/pve/storage.cfg

echo

pvesm status

echo

pass "Module 12 completed successfully."
