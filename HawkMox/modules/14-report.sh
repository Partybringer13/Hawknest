#!/usr/bin/env bash
set -Eeuo pipefail

source "$(dirname "$0")/../lib/common.sh"

header "Module 14 - HawkMox Deployment Report"

REPORT="/root/hawkmox-report.txt"

{
echo "=================================================="
echo " HawkMox Deployment Report"
echo "=================================================="
echo
echo "Date: $(date)"
echo
echo "Hostname : $(hostname)"
echo "Role     : ${ROLE:-unknown}"
echo
echo "Hardware : $(hardware_model)"
echo "CPU      : $(cpu_model)"
echo "Memory   : $(memory_gib) GiB"
echo

echo "========== Cluster =========="
pvecm status

echo
echo "========== Storage =========="
zpool status
echo
zfs list
echo
pvesm status

echo
echo "========== Network =========="
ip addr show vmbr0
echo
ip route

echo
echo "========== Time =========="
chronyc tracking

echo
echo "========== Services =========="
systemctl --no-pager --type=service --state=running \
    | grep -E 'pve|corosync|chrony'

} > "$REPORT"

section "Report"

echo "Saved to:"
echo "$REPORT"

pass "Module 14 completed successfully."
