#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${PROJECT_ROOT}/lib/common.sh"

header "Module 01 - Prerequisites"

############################################################
# Commands
############################################################

section "Checking Required Commands"

for CMD in \
    zpool \
    zfs \
    pvesm \
    pvecm \
    lsblk \
    awk \
    sed \
    grep \
    ping \
    systemctl
do
    require_command "${CMD}"
done

success "Required commands verified."

############################################################
# Environment
############################################################

section "Checking Environment"

require_root

check_proxmox

success "Environment verified."

############################################################
# Storage
############################################################

section "Checking Storage"

verify_disk_exists "${BOOT_DISK}"

verify_disk_exists "${APP_DISK}"

info "Boot Disk"

echo "    Device : ${BOOT_DISK}"
echo "    Model  : $(disk_model "${BOOT_DISK}")"
echo "    Size   : $(disk_size "${BOOT_DISK}")"

echo

info "Application Disk"

echo "    Device : ${APP_DISK}"
echo "    Model  : $(disk_model "${APP_DISK}")"
echo "    Size   : $(disk_size "${APP_DISK}")"

[[ "${BOOT_DISK}" != "${APP_DISK}" ]] \
    || die "BOOT_DISK and APP_DISK cannot be the same."

success "Storage verified."

############################################################
# System
############################################################

section "Checking System"

echo "Hostname : $(hostname)"
echo "Hardware : $(hardware_model)"
echo "CPU      : $(cpu_model)"
echo "Memory   : $(memory_gib) GiB"

success "System verified."

############################################################
# Existing Configuration
############################################################

section "Checking Existing Configuration"

if pool_exists "${POOL_NAME}"
then
    warning "Pool '${POOL_NAME}' already exists."
else
    success "No existing ZFS pool."
fi

if storage_exists "${ZFS_STORAGE_ID}"
then
    warning "Storage '${ZFS_STORAGE_ID}' already exists."
else
    success "No existing ZFS storage detected."
fi

if storage_exists "${DIR_STORAGE_ID}"
then
    warning "Storage '${DIR_STORAGE_ID}' already exists."
else
    success "No existing directory storage detected."
fi

############################################################

section "Summary"

system_summary

echo

success "Module 01 completed successfully."
