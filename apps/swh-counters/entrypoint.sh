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
        ;;
    "swh")
        shift
        declare -a cmd

        if [ "${MEMRAY_ENABLED}" = "true" ]; then
            # we expect MEMRAY_OPTIONS to contain quoted values
            # shellcheck disable=SC2206
            cmd=(memray run --native ${MEMRAY_OPTIONS})
            if [ -n "${MEMRAY_LIVE_REMOTE_PORT}" ]; then
                cmd+=(--live-remote --live-port="${MEMRAY_LIVE_REMOTE_PORT}")
            fi
        fi

        cmd+=(swh "$@")

        set -x
        exec "${cmd[@]}"
        ;;
    *)
        echo Starting the swh-search API server
        exec gunicorn --bind 0.0.0.0:${PORT} \
            --log-level ${LOG_LEVEL} \
            --threads ${THREADS} \
            --workers ${WORKERS} \
            --reload \
            --timeout ${TIMEOUT} \
            --config 'python:swh.core.api.gunicorn_config' \
            'swh.counters.api.server:make_app_from_configfile()'
esac
