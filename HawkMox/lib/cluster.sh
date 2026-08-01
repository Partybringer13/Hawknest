#!/usr/bin/env bash

set -Eeuo pipefail

cluster_exists() {

    [[ -f /etc/pve/corosync.conf ]]

}

cluster_name() {

    pvecm status \
        | awk -F': ' '/Name/ {print $2}'

}

cluster_nodes() {

    pvecm nodes \
        | awk 'NR>2 {count++} END {print count+0}'

}

cluster_quorate() {

    pvecm status \
        | grep -q "Quorate:.*Yes"

}

join_cluster() {

    if cluster_exists
    then
        success "Already in cluster."
        return
    fi

    [[ -n "${CLUSTER_MASTER_IP}" ]] \
        || die "CLUSTER_MASTER_IP not configured."

    info "Joining cluster..."

    pvecm add "${CLUSTER_MASTER_IP}"

}
