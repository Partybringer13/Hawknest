#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 07 - Cluster"

############################################################
section "Cluster Status"

if cluster_exists
then

    success "Already a cluster member."

else

    join_cluster

fi

############################################################
section "Waiting for Quorum"

COUNT=0

until cluster_quorate
do

    ((COUNT++))

    [[ ${COUNT} -gt 30 ]] && die "Cluster quorum not reached."

    sleep 2

done

success "Cluster quorum established."

############################################################
section "Cluster"

pvecm status

echo

success "Module 07 completed successfully."
