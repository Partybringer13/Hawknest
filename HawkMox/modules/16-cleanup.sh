header "Module 16 - Final Cleanup"

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVE="/root/hawkmox-backup.tar.gz"

############################################################
section "Archive HawkMox"

if [[ -d "$PROJECT_ROOT" ]]; then
    tar -czf "$ARCHIVE" \
        -C "$(dirname "$PROJECT_ROOT")" \
        "$(basename "$PROJECT_ROOT")"

    success "Installer archived."
    info "Archive: $ARCHIVE"
else
    warning "Project directory not found."
fi

############################################################
section "APT Cleanup"

apt-get autoremove -y
apt-get autoclean -y
apt-get clean

rm -rf /var/lib/apt/lists/*

success "APT cache cleaned."

############################################################
section "Journal Cleanup"

journalctl --vacuum-time=7d >/dev/null 2>&1 || true
journalctl --vacuum-size=100M >/dev/null 2>&1 || true

success "System journal trimmed."

############################################################
section "Temporary Files"

rm -rf /tmp/*
rm -rf /var/tmp/*

success "Temporary files removed."

############################################################
section "Installer Removal"

if [[ -d "$PROJECT_ROOT" ]]; then
    rm -rf "$PROJECT_ROOT"
    success "Installer removed."
fi

############################################################
section "Filesystem Trim"

fstrim -av || true

############################################################
section "Storage Usage"

df -h /

echo
du -sh /root 2>/dev/null || true

echo
success "Module 16 completed successfully."
