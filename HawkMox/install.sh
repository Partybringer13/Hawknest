#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_TIME=$(date +%s)

source "${PROJECT_ROOT}/configs/config.sh"
source "${PROJECT_ROOT}/lib/logging.sh"
source "${PROJECT_ROOT}/lib/ui.sh"

header "HawkMox Installer"

while IFS= read -r module; do

    echo
    echo "Running $(basename "$module")"
    echo

    if ! bash "$module"; then
        error "Installation failed in $(basename "$module")"
        exit 1
    fi

done < <(
    find "${PROJECT_ROOT}/modules" \
        -maxdepth 1 \
        -type f \
        -name '*.sh' \
        | sort
)

END_TIME=$(date +%s)

echo
success "HawkMox installation complete."
info "Elapsed time: $((END_TIME - START_TIME)) seconds"
