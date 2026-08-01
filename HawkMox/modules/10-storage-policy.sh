#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 10 - Storage Policy"

############################################################
section "Verify Storages"

storage_exists "${ZFS_STORAGE_ID}" \
    || die "${ZFS_STORAGE_ID} missing."

storage_exists "${DIR_STORAGE_ID}" \
    || die "${DIR_STORAGE_ID} missing."

pass "Required storages present."

############################################################
section "Configure ${ZFS_STORAGE_ID}"

pvesm set "${ZFS_STORAGE_ID}" \
    --content images,rootdir \
    --blocksize 16k \
    --sparse 1

pass "${ZFS_STORAGE_ID} configured."

############################################################
section "Configure ${DIR_STORAGE_ID}"

pvesm set "${DIR_STORAGE_ID}" \
    --content iso,vztmpl,backup,snippets,import

pass "${DIR_STORAGE_ID} configured."

############################################################
section "Current Storage Configuration"

cat /etc/pve/storage.cfg

echo

pvesm status

echo

pass "Module 10 completed successfully."
