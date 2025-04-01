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
    "swh")
        shift
        echo "Running swh command $@"
        exec swh $@
        ;;
    "luigi")
        shift
        echo "Running luigid scheduler"
        exec luigid --background \
             --pidfile "${LUIGI_PATH_TO_PIDFILE}" \
             --logdir "${LUIGI_PATH_TO_LOGDIR}" \
             --state-path "${LUIGI_PATH_TO_STATEFILE}"
        ;;
    *)
        echo Unknown command $@
        exit 1
esac
