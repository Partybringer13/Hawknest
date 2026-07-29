#!/usr/bin/env bash

source "$(dirname "$0")/../lib/common.sh"

header "Module 13 - HawkMox Health Check"

PASSCOUNT=0
WARNCOUNT=0
FAILCOUNT=0

ok() {
    echo "[PASS] $1"
    ((PASSCOUNT++))
}

warning() {
    echo "[WARN] $1"
    ((WARNCOUNT++))
}

failure() {
    echo "[FAIL] $1"
    ((FAILCOUNT++))
}

section "Cluster"

if pvecm status >/dev/null 2>&1; then
    if pvecm status | grep -q "Quorate:.*Yes"; then
        ok "Cluster quorum healthy."
    else
        failure "Cluster is NOT quorate."
    fi
else
    warning "Node is not clustered."
fi

section "Time"

if chronyc tracking | grep -q "Leap status.*Normal"; then
    ok "Chrony synchronized."
else
    failure "Chrony not synchronized."
fi

section "ZFS"

if zpool status hawktank >/dev/null 2>&1; then
    if zpool status hawktank | grep -q "state: ONLINE"; then
        ok "hawktank ONLINE."
    else
        failure "hawktank degraded."
    fi
else
    failure "hawktank missing."
fi

section "Storage"

grep -q "^zfspool: hawktank" /etc/pve/storage.cfg \
    && ok "hawktank registered." \
    || failure "hawktank not registered."

grep -q "^dir: hawkfiles" /etc/pve/storage.cfg \
    && ok "hawkfiles registered." \
    || failure "hawkfiles not registered."

grep -q "^dir: local" /etc/pve/storage.cfg \
    && warning "Unexpected local storage configured."

grep -q "^lvmthin: local-lvm" /etc/pve/storage.cfg \
    && warning "Unexpected local-lvm configured."

section "Filesystem"

mountpoint -q /srv/hawkmox \
    && ok "/srv/hawkmox mounted." \
    || warning "/srv/hawkmox not mounted."

section "Services"

for svc in pvedaemon pveproxy pve-cluster chrony; do
    if systemctl is-active --quiet "$svc"; then
        ok "$svc running."
    else
        failure "$svc NOT running."
    fi
done

section "SSD"

systemctl is-enabled fstrim.timer >/dev/null 2>&1 \
    && ok "fstrim enabled." \
    || warning "fstrim not enabled."

section "ARC"

ARC=$(cat /sys/module/zfs/parameters/zfs_arc_max)

printf "ARC Limit : %.1f GiB\n" "$(awk "BEGIN{print $ARC/1024/1024/1024}")"

section "Summary"

echo
echo "PASS : $PASSCOUNT"
echo "WARN : $WARNCOUNT"
echo "FAIL : $FAILCOUNT"
echo

if [[ $FAILCOUNT -eq 0 ]]; then
    pass "Node health check passed."
else
    fail "Health check detected failures."
fi
