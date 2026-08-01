#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 08 - Node Role"

############################################################

section "Current Role"

CURRENT_ROLE="$(get_role)"

echo "Current Role : ${CURRENT_ROLE}"

############################################################

section "Configure"

if [[ "${CURRENT_ROLE}" == "unknown" ]]
then

    ROLE="application"

    set_role "${ROLE}"

    success "Assigned default role '${ROLE}'."

else

    success "Role already configured."

fi

############################################################

section "Runtime"

echo

echo "Hostname : $(hostname)"

echo "Role     : $(get_role)"

echo

success "Module 08 completed successfully."
