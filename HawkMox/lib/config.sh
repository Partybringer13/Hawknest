#!/usr/bin/env bash

set -Eeuo pipefail

CONFIG_FILE="${PROJECT_ROOT}/configs/hawkmox.conf"

load_config() {

    [[ -f "${CONFIG_FILE}" ]] || return

    source "${CONFIG_FILE}"

}

save_config() {

cat > "${CONFIG_FILE}" <<EOF
ROLE=${ROLE}
EOF

}

set_role() {

    ROLE="$1"

    save_config

}

get_role() {

    load_config

    echo "${ROLE:-unknown}"

}
