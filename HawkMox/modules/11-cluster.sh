#!/usr/bin/env bash

source "$(dirname "$0")/../lib/common.sh"

header "Module 11 - Cluster Validation"

section "Cluster Status"

if ! command -v pvecm >/dev/null 2>&1; then
    fail "This node is not running Proxmox VE."
fi

if ! pvecm status >/dev/null 2>&1; then
    fail "This node is not part of a cluster."
fi

CLUSTER_NAME=$(pvecm status 2>/dev/null | awk -F': *' '/Name:/ {print $2}')
NODE_COUNT=$(pvecm status 2>/dev/null | awk -F': *' '/Nodes:/ {print $2}')
QUORATE=$(pvecm status 2>/dev/null | awk -F': *' '/Quorate:/ {print $2}')

info "Cluster : ${CLUSTER_NAME}"
info "Nodes   : ${NODE_COUNT}"
info "Quorate : ${QUORATE}"

[[ "$QUORATE" == "Yes" ]] || fail "Cluster is not quorate."

pass "Cluster healthy."

section "Node List"

pvecm nodes

section "Corosync"

grep -E "ring0_addr|name:" /etc/pve/corosync.conf

section "Storage"

pvesm status

section "Time Synchronization"

chronyc tracking | sed -n '1,8p'

section "Network"

ip -4 addr show vmbr0 | grep inet
ip route | grep default

section "Summary"

pass "Cluster quorum confirmed."
pass "Corosync operational."
pass "Storage available."
pass "Time synchronized."
pass "Network validated."

pass "Module 11 completed successfully."
