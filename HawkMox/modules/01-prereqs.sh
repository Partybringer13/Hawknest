#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${PROJECT_ROOT}/lib/common.sh"

header "Module 01 - Prerequisites"

section "Checking Required Commands"

REQUIRED_COMMANDS=(
    awk
    basename
    blockdev
    find
    findmnt
    grep
    hostname
    hostnamectl
    lsblk
    lscpu
    mkdir
    pvesm
    pvesh
    sgdisk
    systemctl
    udevadm
    wipefs
    zfs
    zpool
)

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    require_command "${cmd}"
done

success "Required commands verified."

section "Checking Environment"

require_root
check_proxmox
check_zfs

success "Environment verified."

section "Checking Storage"

verify_disk_exists "${BOOT_DISK}"
verify_disk_exists "${APP_DISK}"

[[ "${BOOT_DISK}" != "${APP_DISK}" ]] \
    || die "BOOT_DISK and APP_DISK cannot be the same device."

BOOT_SIZE=$(disk_size "${BOOT_DISK}")
APP_SIZE=$(disk_size "${APP_DISK}")

BOOT_MODEL=$(disk_model "${BOOT_DISK}")
APP_MODEL=$(disk_model "${APP_DISK}")

info "Boot Disk"
echo "    Device : ${BOOT_DISK}"
echo "    Model  : ${BOOT_MODEL}"
echo "    Size   : ${BOOT_SIZE}"

echo

info "Application Disk"
echo "    Device : ${APP_DISK}"
echo "    Model  : ${APP_MODEL}"
echo "    Size   : ${APP_SIZE}"

success "Storage verified."

section "Checking System"

HOSTNAME="$(hostname)"

MODEL="$(hardware_model)"

CPU="$(cpu_model)"

MEMORY="$(memory_gib)"

echo "Hostname : ${HOSTNAME}"
echo "Hardware : ${MODEL}"
echo "CPU      : ${CPU}"
echo "Memory   : ${MEMORY} GiB"

success "System verified."

section "Checking Existing Configuration"

if pool_exists "${POOL_NAME}"; then
    warning "Pool '${POOL_NAME}' already exists."
else
    success "No existing ZFS pool detected."
fi

if storage_exists "${ZFS_STORAGE_ID}"; then
    warning "Storage '${ZFS_STORAGE_ID}' already exists."
else
    success "No existing ZFS storage detected."
fi

if storage_exists "${DIR_STORAGE_ID}"; then
    warning "Storage '${DIR_STORAGE_ID}' already exists."
else
    success "No existing directory storage detected."
fi

section "Summary"

system_summary

echo

success "Module 01 completed successfully."
