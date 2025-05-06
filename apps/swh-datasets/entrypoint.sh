#!/bin/bash

set -e

if [ -n "${SWH_DEBUG_ENTRYPOINT}" ]; then
    set -x
fi

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
        case "${APP_NAME}" in
            "datasets")
                echo "Running datasets export: `swh datasets luigi $@`"
                exec swh datasets luigi "$@"
                ;;
            "luigi")
                echo "Running luigid scheduler"
                exec luigid \
                     --pidfile "${LUIGI_PATH_TO_PIDFILE}" \
                     --logdir "${LUIGI_PATH_TO_LOGDIR}" \
                     --state-path "${LUIGI_PATH_TO_STATEFILE}" \
                     --port "${PORT}" \
                     --address "0.0.0.0"
                ;;
            *)
                echo "Unknown command $@"
                exit 1
        esac
esac
