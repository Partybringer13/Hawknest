#!/usr/bin/env bash

CONFIG_FILE="${PROJECT_ROOT}/config/hawkmox.conf"

[[ -f "${CONFIG_FILE}" ]] || {
    echo
    echo "Configuration file not found:"
    echo "  ${CONFIG_FILE}"
    echo
    exit 1
}

source "${CONFIG_FILE}"

############################################
# Interactive Configuration
############################################

if [[ -z "${CLUSTER_MASTER}" ]]; then

    echo
    read -rp "Cluster master IP: " CLUSTER_MASTER

    sed -i \
        "s|^CLUSTER_MASTER=.*|CLUSTER_MASTER=\"${CLUSTER_MASTER}\"|" \
        "${CONFIG_FILE}"

fi

if [[ -z "${DNS_SERVER}" ]]; then

    DNS_SERVER="$(ip route | awk '/default/ {print $3}')"

    sed -i \
        "s|^DNS_SERVER=.*|DNS_SERVER=\"${DNS_SERVER}\"|" \
        "${CONFIG_FILE}"

fi

if [[ -z "${TIME_SERVER}" ]]; then

    TIME_SERVER="${DNS_SERVER}"

    sed -i \
        "s|^TIME_SERVER=.*|TIME_SERVER=\"${TIME_SERVER}\"|" \
        "${CONFIG_FILE}"

fi
