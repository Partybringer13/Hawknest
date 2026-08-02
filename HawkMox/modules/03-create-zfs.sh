#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${PROJECT_ROOT}/lib/common.sh"

header "Module 03 - Create ZFS"

############################################################

section "Pre-flight Checks"

check_zfs

verify_disk_exists "${APP_DISK}"

ROOTDISK="$(findmnt -n -o SOURCE / | sed 's/p[0-9]*$//')"

[[ "${APP_DISK}" != "${ROOTDISK}" ]] \
    || die "APP_DISK points at the boot disk."

info "Application Disk : ${APP_DISK}"
info "Pool             : ${POOL_NAME}"

############################################################

section "Creating Storage"

ensure_pool

ensure_file_dataset

############################################################

section "Status"

zpool status "${POOL_NAME}"

echo

zfs list

echo

success "Module 03 completed successfully."
