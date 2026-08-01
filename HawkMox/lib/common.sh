#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${PROJECT_ROOT}/configs/config.sh"
source "${PROJECT_ROOT}/lib/logging.sh"
source "${PROJECT_ROOT}/lib/ui.sh"

############################################################
# Requirements
############################################################

require_command() {
    command -v "$1" >/dev/null 2>&1 \
        || die "Missing required command: $1"
}

check_proxmox() {

    [[ -f /etc/pve/storage.cfg ]] \
        || die "This does not appear to be a Proxmox host."

}

check_zfs() {

    require_command zpool
    require_command zfs

}

############################################################
# Disk helpers
############################################################

verify_disk_exists() {

    local disk="$1"

    [[ -b "${disk}" ]] \
        || die "Disk ${disk} not found."

}

disk_size() {

    lsblk -dn -o SIZE "$1"

}

disk_model() {

    lsblk -dn -o MODEL "$1"

}

############################################################
# Storage helpers
############################################################

pool_exists() {

    zpool list -H "$1" >/dev/null 2>&1

}

dataset_exists() {

    zfs list -H "$1" >/dev/null 2>&1

}

storage_exists() {

    pvesm status 2>/dev/null | awk '{print $1}' | grep -qx "$1"

}

############################################################
# Filesystem helpers
############################################################

ensure_directory() {

    local dir="$1"

    mkdir -p "$dir"

}

############################################################
# System helpers
############################################################

cpu_model() {

    lscpu | awk -F: '/Model name/{
        gsub(/^[ \t]+/, "", $2)
        print $2
    }'

}

memory_gib() {

    awk '/MemTotal/{
        printf "%.1f", $2/1024/1024
    }' /proc/meminfo

}

hardware_model() {

    tr -d '\0' </sys/class/dmi/id/product_name

}

############################################################
# Service helpers
############################################################

restart_service() {

    local service="$1"

    systemctl restart "$service"

}

enable_service() {

    local service="$1"

    systemctl enable "$service"

}

############################################################
# Safety
############################################################

assert_not_mounted() {

    local device="$1"

    if mount | grep -q "^${device}"; then
        die "${device} is mounted."
    fi

}

assert_pool_missing() {

    local pool="$1"

    pool_exists "$pool" && die "Pool ${pool} already exists."

}

############################################################
# Logging
############################################################

system_summary() {

    info "Hardware : $(hardware_model)"
    info "CPU      : $(cpu_model)"
    info "Memory   : $(memory_gib) GiB"
    info "Boot Disk: ${BOOT_DISK} ($(disk_size "${BOOT_DISK}"))"
    info "App Disk : ${APP_DISK} ($(disk_size "${APP_DISK}"))"

}
