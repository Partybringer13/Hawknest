#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 13 - HawkMox Health Check"

############################################################
section "Cluster"

cluster_quorate || die "Cluster is not quorate."

pass "Cluster quorum healthy."

############################################################
section "Corosync"

systemctl is-active --quiet corosync

pass "Corosync running."

############################################################
section "Storage"

pool_exists "${POOL_NAME}" \
    || die "Pool '${POOL_NAME}' missing."

pass "${POOL_NAME} online."

dataset_exists "${POOL_NAME}/${VM_DATASET}" \
    || die "VM dataset missing."

pass "${VM_DATASET} dataset present."

storage_exists "${ZFS_STORAGE_ID}" \
    || die "${ZFS_STORAGE_ID} storage missing."

pass "${ZFS_STORAGE_ID} registered."

storage_exists "${DIR_STORAGE_ID}" \
    || die "${DIR_STORAGE_ID} storage missing."

pass "${DIR_STORAGE_ID} registered."

############################################################
section "Network"

GW="$(gateway)"

[[ -n "${GW}" ]] || die "No default gateway."

info "Gateway : ${GW}"

ping -c2 -W2 "${GW}" >/dev/null

pass "Gateway reachable."

ping -c2 -W2 1.1.1.1 >/dev/null

pass "Internet reachable."

############################################################
section "Time"

chronyc tracking | grep -q "Leap status.*Normal"

pass "Chrony synchronized."

############################################################
section "Services"

SERVICES=(
    pvedaemon
    pveproxy
    pvestatd
    pve-cluster
)

for SERVICE in "${SERVICES[@]}"
do

    systemctl is-active --quiet "${SERVICE}" \
        || die "${SERVICE} not running."

    pass "${SERVICE} running."

done

############################################################
section "Resources"

echo "CPU    : $(cpu_model)"
echo "Memory : $(memory_gib) GiB"

echo "ARC    : $(awk '/size/ {print $3; exit}' /proc/spl/kstat/zfs/arcstats 2>/dev/null || echo "Unavailable")"

############################################################
section "Summary"

zpool list

echo

pvesm status

echo

pass "Module 13 completed successfully."
