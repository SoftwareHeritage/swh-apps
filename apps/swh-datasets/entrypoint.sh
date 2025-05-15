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
        # luigi scheduler command
        echo "Running luigid scheduler"
        exec luigid \
             --pidfile "${LUIGI_PATH_TO_PIDFILE}" \
             --logdir "${LUIGI_PATH_TO_LOGDIR}" \
             --state-path "${LUIGI_PATH_TO_STATEFILE}" \
             --port "${PORT}" \
             --address "0.0.0.0"
        ;;
esac
