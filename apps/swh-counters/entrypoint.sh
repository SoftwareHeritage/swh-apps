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
        EXTRA_CLI_FLAGS=()
        if [ -n "${SWH_LOG_CONFIG_JSON}" ]; then
            EXTRA_CLI_FLAGS+=('--log-config-json' "${SWH_LOG_CONFIG_JSON}")
        fi
        if [ -n "${STATSD_HOST}" -a -n "${STATSD_PORT}" ]; then
            EXTRA_CLI_FLAGS+=('--statsd-host' "${STATSD_HOST}:${STATSD_PORT}")
        fi
        if [ -n "${STATSD_SERVICE_TYPE}" ]; then
            EXTRA_CLI_FLAGS+=('--statsd-prefix' "${STATSD_SERVICE_TYPE}")
        fi

        echo 'Starting the swh-counters API server'
        exec gunicorn --bind "0.0.0.0:${PORT}" \
             --log-level "${SWH_LOG_LEVEL:-INFO}" \
             "${EXTRA_CLI_FLAGS[@]}" \
             --threads "${THREADS}" \
             --workers "${WORKERS}" \
             --timeout "${TIMEOUT}" \
             --reload \
             --config 'python:swh.core.api.gunicorn_config' \
             'swh.counters.api.server:make_app_from_configfile()'
esac
