#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${PROJECT_ROOT}/lib/common.sh"

header "Module 03 - Create ZFS"

section "Pre-flight Checks"

check_zfs
verify_disk_exists "${APP_DISK}"
assert_pool_missing "${POOL_NAME}"

ROOTDISK="$(findmnt -n -o SOURCE / | sed 's/p[0-9]*$//')"

if [[ "${APP_DISK}" == "${ROOTDISK}" ]]; then
    die "APP_DISK points to the boot device (${APP_DISK}). Refusing to continue."
fi

info "Application Disk : ${APP_DISK}"
info "Pool Name        : ${POOL_NAME}"

section "Destroy Existing Signatures"

wipefs -af "${APP_DISK}" >/dev/null 2>&1 || true
sgdisk --zap-all "${APP_DISK}" >/dev/null 2>&1 || true

section "Creating ZFS Pool"

zpool create \
    -f \
    -o ashift=12 \
    -O compression=lz4 \
    -O atime=off \
    -O xattr=sa \
    -O acltype=posixacl \
    -O mountpoint=none \
    "${POOL_NAME}" \
    "${APP_DISK}"

section "Creating Datasets"

zfs create \
    -o mountpoint=none \
    "${POOL_NAME}/vmstore"

zfs create \
    -o mountpoint=/srv/hawkmox \
    "${POOL_NAME}/files"

zfs set compression=lz4 "${POOL_NAME}/files"

section "Pool Status"

zpool status "${POOL_NAME}"

echo

zfs list

success "Module 03 completed successfully."
