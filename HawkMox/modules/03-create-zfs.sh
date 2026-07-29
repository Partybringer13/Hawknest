#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 03 - Create ZFS"

section "Pre-flight Checks"

verify_disk_exists "${APP_DISK}"

if pool_exists "${POOL_NAME}"; then
    warning "Pool '${POOL_NAME}' already exists."
    info "Skipping ZFS creation."
    exit 0
fi

echo
echo "This will COMPLETELY ERASE:"
echo
echo "    ${APP_DISK}"
echo
echo "Type YES to continue."

confirm || die "Cancelled."

section "Destroy Existing Signatures"

wipefs -af "${APP_DISK}"

sgdisk --zap-all "${APP_DISK}"

blockdev --rereadpt "${APP_DISK}" || true

udevadm settle

section "Partition Disk"

sgdisk \
    -n1:1M:0 \
    -t1:BF01 \
    "${APP_DISK}"

blockdev --rereadpt "${APP_DISK}" || true

udevadm settle

PARTITION="${APP_DISK}1"

for i in {1..10}; do

    [[ -b "${PARTITION}" ]] && break

    sleep 1

done

[[ -b "${PARTITION}" ]] \
    || die "Partition was not created."

section "Create ZFS Pool"

zpool create \
    -f \
    -o ashift="${ASHIFT}" \
    -O compression="${COMPRESSION}" \
    -O atime="${ATIME}" \
    -O xattr=sa \
    -O acltype=posixacl \
    -O normalization=formD \
    -O mountpoint=none \
    "${POOL_NAME}" \
    "${PARTITION}"

zpool set autotrim="${AUTOTRIM}" "${POOL_NAME}"

section "Create Datasets"

zfs create \
    -o mountpoint=none \
    "${POOL_NAME}/${VM_DATASET}"

zfs create \
    -o mountpoint="${FILE_MOUNT}" \
    "${POOL_NAME}/${FILE_DATASET}"

mkdir -p "${ISO_DIR}"
mkdir -p "${TEMPLATE_DIR}"
mkdir -p "${BACKUP_DIR}"
mkdir -p "${SNIPPET_DIR}"
mkdir -p "${IMPORT_DIR}"

section "Verification"

echo
zpool status

echo
zfs list

success "Module 03 completed successfully."
