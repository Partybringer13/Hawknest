#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 14 - HawkMox Deployment Report"

REPORT="/root/hawkmox-report.txt"

ROLE="$(get_role)"

cat > "${REPORT}" <<EOF
==================================================
 HawkMox Deployment Report
==================================================

Date: $(date)

Hostname : $(hostname)
Role     : ${ROLE}

Hardware : $(hardware_model)
CPU      : $(cpu_model)
Memory   : $(memory_gib) GiB

========== Cluster ==========
$(pvecm status)

========== ZFS ==========
$(zpool status)

========== Storage ==========
$(pvesm status)

========== Network ==========
$(ip -br addr)

========== Routes ==========
$(ip route)

========== Chrony ==========
$(chronyc tracking)

EOF

section "Report"

echo "Saved to:"
echo "${REPORT}"

pass "Module 14 completed successfully."
