#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${PROJECT_ROOT}/configs/config.sh"
source "${PROJECT_ROOT}/lib/logging.sh"
source "${PROJECT_ROOT}/lib/ui.sh"

header "HawkMox Installer"

for module in $(find "${PROJECT_ROOT}/modules" -maxdepth 1 -type f -name '*.sh' | sort); do

    echo
    echo "Running $(basename "$module")"
    echo

    bash "$module"

done

echo
success "HawkMox installation complete."
