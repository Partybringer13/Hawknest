#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

############################################################
# Configuration
############################################################

source "${PROJECT_ROOT}/configs/config.sh"

############################################################
# Libraries
############################################################

source "${PROJECT_ROOT}/lib/logging.sh"
source "${PROJECT_ROOT}/lib/ui.sh"
source "${PROJECT_ROOT}/lib/config.sh"
source "${PROJECT_ROOT}/lib/storage.sh"
source "${PROJECT_ROOT}/lib/network.sh"
source "${PROJECT_ROOT}/lib/cluster.sh"

############################################################
# Requirements
############################################################

require_command() {

    command -v "$1" >/dev/null \
        || die "Missing required command: $1"

}

check_proxmox() {

    [[ -f /etc/pve/storage.cfg ]] \
        || die "This host is not Proxmox."

}

check_zfs() {

    require_command zpool
    require_command zfs

}

############################################################
# Disk Helpers
############################################################

verify_disk_exists() {

    [[ -b "$1" ]] \
        || die "Disk '$1' not found."

}

disk_size() {

    lsblk -dn -o SIZE "$1"

}

disk_model() {

    lsblk -dn -o MODEL "$1"

}

############################################################
# System Summary
############################################################

cpu_model() {

    lscpu \
        | awk -F: '/Model name/{
            gsub(/^[ \t]+/,"",$2)
            print $2
        }'

}

memory_gib() {

    awk '/MemTotal/{
        printf "%.1f",$2/1024/1024
    }' /proc/meminfo

}

hardware_model() {

    tr -d '\0' </sys/class/dmi/id/product_name

}

system_summary() {

    info "Hardware : $(hardware_model)"
    info "CPU      : $(cpu_model)"
    info "Memory   : $(memory_gib) GiB"
    info "Boot Disk: ${BOOT_DISK} ($(disk_size "${BOOT_DISK}"))"
    info "App Disk : ${APP_DISK} ($(disk_size "${APP_DISK}"))"

}
