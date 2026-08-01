#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 05 - System Optimization"

############################################################
# CPU Detection
############################################################

CPU="$(cpu_model)"
MEMORY_GB="$(awk '/MemTotal/ {printf "%.0f",$2/1024/1024}' /proc/meminfo)"

info "CPU    : ${CPU}"
info "Memory : ${MEMORY_GB} GiB"

############################################################
# Configure ZFS ARC
############################################################

section "Configuring ZFS ARC"

ARC_GB=$(( MEMORY_GB / 4 ))

if (( ARC_GB < 4 )); then
    ARC_GB=4
fi

if (( ARC_GB > 8 )); then
    ARC_GB=8
fi

ARC_BYTES=$(( ARC_GB * 1024 * 1024 * 1024 ))

cat >/etc/modprobe.d/zfs.conf <<EOF
options zfs zfs_arc_max=${ARC_BYTES}
EOF

success "ARC limited to ${ARC_GB} GiB"

############################################################
# Sysctl
############################################################

section "Applying sysctl tuning"

cat >/etc/sysctl.d/99-hawkmox.conf <<EOF
vm.swappiness=1
vm.vfs_cache_pressure=50
vm.dirty_background_ratio=5
vm.dirty_ratio=20
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
net.core.somaxconn=4096
EOF

sysctl --system >/dev/null

success "Kernel tuning applied."

############################################################
# Journald
############################################################

section "Configuring journald"

mkdir -p /etc/systemd/journald.conf.d

cat >/etc/systemd/journald.conf.d/hawkmox.conf <<EOF
[Journal]
Storage=persistent
SystemMaxUse=250M
RuntimeMaxUse=100M
Compress=yes
EOF

systemctl restart systemd-journald

success "journald configured."

############################################################
# SSD TRIM
############################################################

section "Enabling SSD TRIM"

systemctl enable fstrim.timer >/dev/null
systemctl start fstrim.timer

success "fstrim enabled."

############################################################
# CPU Governor
############################################################

section "CPU Governor"

if [[ -d /sys/devices/system/cpu/cpu0/cpufreq ]]; then

    for GOV in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance > "${GOV}" || true
    done

    success "CPU governor set to performance."

else

    warning "CPU governor not available."

fi

############################################################
# HawkMox log rotation
############################################################

section "Configuring logrotate"

cat >/etc/logrotate.d/hawkmox <<EOF
/var/log/hawkmox.log {
    weekly
    rotate 8
    compress
    missingok
    notifempty
    copytruncate
}
EOF

success "logrotate configured."

############################################################
# Summary
############################################################

echo
echo "ARC Limit : ${ARC_GB} GiB"
echo "TRIM      : Enabled"
echo "Journald  : Persistent"

echo

success "Module 05 completed successfully."
