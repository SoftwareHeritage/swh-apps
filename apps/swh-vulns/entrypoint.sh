#!/bin/bash

set -e

case "$1" in
    "shell")
        shift
        if (( $# == 0)); then
            exec bash -i
        else
            "$@"
        fi
        exit 0
        ;;
    *)
        echo "Starting grpc swh-vulns server"
        exec swh-vulns-grpc-serve \
          --db "${VULN_DB_PATH}" \
          --commit2vuln "${VULN_COMMIT2VULN_PATH}" \
          --subgraphwccs "${VULN_SUBGRAPHWCCS_PATH}" \
          --graph "${GRAPH_DATASET_PATH}" \
          --bind "0.0.0.0:${PORT}"

esac
