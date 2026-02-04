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
            exec "$@"
        fi
        exit 0
        ;;
    "swh")
        # swh commands, i.e. swh export, swh datasets, ...
        shift
        exec swh "$@"
        ;;
    *)
        EXTRA_CLI_FLAGS=()
        if [ -n "${LUIGI_PATH_TO_PIDFILE}" ]; then
            EXTRA_CLI_FLAGS+=('--pidfile' "${LUIGI_PATH_TO_PIDFILE}")
        fi
        if [ -n "${LUIGI_PATH_TO_LOGDIR}" ]; then
            EXTRA_CLI_FLAGS+=('--logdir' "${LUIGI_PATH_TO_LOGDIR}")
        fi
        if [ -n "${LUIGI_PATH_TO_STATEFILE}" ]; then
            EXTRA_CLI_FLAGS+=('--state-path' "${LUIGI_PATH_TO_STATEFILE}")
        fi

        # luigi scheduler command
        echo "Running luigid scheduler"
        exec luigid \
             "${EXTRA_CLI_FLAGS[@]}" \
             --port "${PORT}" \
             --address "0.0.0.0"
        ;;
esac
