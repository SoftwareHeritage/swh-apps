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
        echo "Running swh command $@"
        exec swh "$@"
        ;;
    "create-object-reference-partitions"|"create-object-references-partitions")
        echo "Running swh storage create-object-reference-partitions $(date +%Y-%m-%d) $(date -d '+1 month' +%Y-%m-%d)"
        exec swh storage create-object-reference-partitions "$(date +%Y-%m-%d)" "$(date -d '+1 month' +%Y-%m-%d)"
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

        echo 'Starting the swh-storage API server'
        exec gunicorn --bind "0.0.0.0:${PORT}" \
             --log-level "${SWH_LOG_LEVEL:-INFO}" \
             "${EXTRA_CLI_FLAGS[@]}" \
             --threads "${THREADS}" \
             --workers "${WORKERS}" \
             --timeout "${TIMEOUT}" \
             --config 'python:swh.core.api.gunicorn_config' \
             'swh.storage.api.server:make_app_from_configfile()'
        ;;
esac
