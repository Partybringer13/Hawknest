#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/../lib/common.sh"

header "Module 13 - HawkMox Health Check"

############################################################
section "Cluster"

if pvecm status | grep -q "Quorate:.*Yes"; then
    success "Cluster quorum healthy."
else
    die "Cluster is not quorate."
fi

############################################################
section "Corosync"

systemctl is-active --quiet corosync \
    && success "Corosync running." \
    || die "Corosync not running."

############################################################
section "Storage"

pool_exists hawktank \
    && success "hawktank online." \
    || die "hawktank missing."

dataset_exists hawktank/vmstore \
    && success "vmstore dataset present." \
    || die "vmstore dataset missing."

storage_exists hawktank \
    && success "hawktank registered." \
    || die "hawktank storage missing."

storage_exists hawkfiles \
    && success "hawkfiles registered." \
    || die "hawkfiles storage missing."

############################################################
section "Network"

GATEWAY="$(ip route | awk '/default/ {print $3; exit}')"

info "Gateway : ${GATEWAY}"

ping -c1 -W2 "${GATEWAY}" >/dev/null 2>&1 \
    && success "Gateway reachable." \
    || die "Gateway unreachable."

ping -c1 -W2 1.1.1.1 >/dev/null 2>&1 \
    && success "Internet reachable." \
    || warning "Internet unreachable."

############################################################
section "Time"

if chronyc tracking | grep -q "Leap status.*Normal"; then
    success "Chrony synchronized."
else
    warning "Chrony not synchronized."
fi

############################################################
section "Services"

for svc in pvedaemon pveproxy pvestatd pve-cluster; do
    if systemctl is-active --quiet "$svc"; then
        success "$svc running."
    else
        warning "$svc not running."
    fi
done

############################################################
section "Resources"

echo "CPU    : $(cpu_model)"
echo "Memory : $(memory_gib) GiB"

ARC_BYTES="$(cat /sys/module/zfs/parameters/zfs_arc_max 2>/dev/null || echo 0)"

if [[ "$ARC_BYTES" -gt 0 ]]; then
    ARC_GIB=$(( ARC_BYTES / 1024 / 1024 / 1024 ))
    echo "ARC    : ${ARC_GIB} GiB"
else
    echo "ARC    : Unknown"
fi

############################################################
section "Summary"

zpool list
echo
pvesm status

success "Module 13 completed successfully."
