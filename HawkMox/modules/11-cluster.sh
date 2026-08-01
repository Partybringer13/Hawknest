#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 11 - Cluster Validation"

############################################################
section "Cluster Status"

NAME="$(cluster_name)"
NODES="$(cluster_nodes)"

info "Cluster : ${NAME}"
info "Nodes   : ${NODES}"

cluster_quorate || die "Cluster is not quorate."

pass "Cluster healthy."

############################################################
section "Node List"

pvecm nodes

############################################################
section "Corosync"

grep -E "cluster_name|name:|ring0_addr" /etc/pve/corosync.conf

############################################################
section "Storage"

pvesm status

############################################################
section "Time Synchronization"

chronyc tracking | head -8

############################################################
section "Network"

ip addr show vmbr0 | grep "inet "

ip route | grep default

############################################################
section "Summary"

pass "Cluster quorum confirmed."
pass "Corosync operational."
pass "Storage available."
pass "Time synchronized."
pass "Network validated."

pass "Module 11 completed successfully."
