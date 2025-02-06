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

        echo 'Starting the swh-graphql API server'
        exec gunicorn --bind "0.0.0.0:${PORT}" \
             --log-level "${SWH_LOG_LEVEL:-INFO}" \
             "${EXTRA_CLI_FLAGS[@]}" \
             --threads "${THREADS}" \
             --workers "${WORKERS}" \
             --timeout "${TIMEOUT}" \
             --config 'python:swh.graphql.gunicorn_config' \
             --worker-class 'uvicorn.workers.UvicornWorker' \
             'swh.graphql.server:make_app_from_configfile()'
        ;;
esac
