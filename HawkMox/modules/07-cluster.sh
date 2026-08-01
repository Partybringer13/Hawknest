#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 07 - Cluster"

section "Cluster Detection"

if pvecm status >/dev/null 2>&1; then

    if pvecm status | grep -q "Cluster name"; then

        success "Node already belongs to a cluster."

        pvecm status

        exit 0

    fi

fi

section "Joining Cluster"

[[ -n "${CLUSTER_MASTER_IP}" ]] || die "CLUSTER_MASTER not configured."

info "Cluster Master: ${CLUSTER_MASTER_IP}"

echo
echo "About to join cluster '${CLUSTER_NAME}'"
echo

read -rp "Type YES to continue: " CONFIRM

[[ "${CONFIRM}" == "YES" ]] || die "Cancelled."

pvecm add "${CLUSTER_MASTER_IP}"

section "Verification"

echo

pvecm status

echo

pvecm nodes

success "Cluster successfully joined."
