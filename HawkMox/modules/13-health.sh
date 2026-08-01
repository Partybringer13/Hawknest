#!/usr/bin/env bash
set -Eeuo pipefail

source "$(dirname "$0")/../lib/common.sh"

header "Module 13 - HawkMox Health Check"

############################################################
section "Cluster"

if pvecm status | grep -q "Quorate:.*Yes"; then
    pass "Cluster quorum healthy."
else
    fail "Cluster is not quorate."
fi

############################################################
section "Corosync"

systemctl is-active --quiet corosync \
    && pass "Corosync running." \
    || fail "Corosync stopped."

############################################################
section "Storage"

zpool status hawktank >/dev/null \
    && pass "hawktank online." \
    || fail "hawktank unavailable."

dataset_exists hawktank/vmstore \
    && pass "vmstore dataset present." \
    || fail "vmstore missing."

storage_exists hawktank \
    && pass "hawktank registered." \
    || fail "hawktank storage missing."

storage_exists hawkfiles \
    && pass "hawkfiles registered." \
    || fail "hawkfiles storage missing."

############################################################
section "Network"

ping -c1 -W1 "$GATEWAY" >/dev/null \
    && pass "Gateway reachable." \
    || fail "Gateway unreachable."

ping -c1 -W2 1.1.1.1 >/dev/null \
    && pass "Internet reachable." \
    || fail "Internet unreachable."

############################################################
section "Time"

if chronyc tracking | grep -q "Leap status.*Normal"; then
    pass "Chrony synchronized."
else
    fail "Chrony not synchronized."
fi

############################################################
section "Services"

for svc in pvedaemon pveproxy pvestatd pve-cluster; do
    if systemctl is-active --quiet "$svc"; then
        pass "$svc running."
    else
        fail "$svc stopped."
    fi
done

############################################################
section "Resources"

echo "CPU    : $(cpu_model)"
echo "Memory : $(memory_gib) GiB"
echo "ARC    : $(cat /sys/module/zfs/parameters/zfs_arc_max)"

############################################################
section "Summary"

zpool list
echo
pvesm status

pass "Module 13 completed successfully."
