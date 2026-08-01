#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${PROJECT_ROOT}/lib/common.sh"

###############################################
# Installer
###############################################

header "HawkMox Installer"
START_TIME=$(date +%s)

require_root

START=1
END=999

usage() {
cat <<EOF

Usage:

./install.sh
    Run every module

./install.sh 7
    Resume from module 7

./install.sh 7 10
    Run modules 7 through 10

EOF
}

###############################################
# Parse arguments
###############################################

case $# in

0)
    ;;

1)

    [[ "$1" =~ ^[0-9]+$ ]] || {
        usage
        exit 1
    }

    START="$1"
    ;;

2)

    [[ "$1" =~ ^[0-9]+$ ]] || exit 1
    [[ "$2" =~ ^[0-9]+$ ]] || exit 1

    START="$1"
    END="$2"
    ;;

*)

    usage
    exit 1

esac

###############################################
# Modules
###############################################

mapfile -t MODULES < <(

find "${PROJECT_ROOT}/modules" \
    -maxdepth 1 \
    -type f \
    -name '*.sh' \
| sort

)

###############################################
# Execute
###############################################

for MODULE in "${MODULES[@]}"
do

    NUMBER="$(basename "$MODULE" | cut -d- -f1)"

    NUMBER=$((10#$NUMBER))

    if (( NUMBER < START || NUMBER > END ))
    then
        continue
    fi

    echo
    echo "Running $(basename "$MODULE")"
    echo

    if ! bash "$MODULE"
    then
        die "Installation failed in $(basename "$MODULE")"
    fi

done

echo
END_TIME=$(date +%s)

ELAPSED=$((END_TIME-START_TIME))

echo

success "HawkMox installation completed successfully."

info "Elapsed Time : ${ELAPSED} seconds"
