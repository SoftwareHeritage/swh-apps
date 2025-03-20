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
        exec swh $@
        ;;
    *)
        EXTRA_CLI_FLAGS=()
        if [ -n "${STATSD_HOST}" -a -n "${STATSD_PORT}" ]; then
            EXTRA_CLI_FLAGS+=('--statsd-host' "${STATSD_HOST}:${STATSD_PORT}")
        fi
        case "${PROVENANCE_TYPE}" in
            "rpc")
                if [ -n "${SWH_LOG_CONFIG_JSON}" ]; then
                    EXTRA_CLI_FLAGS+=('--log-config-json' "${SWH_LOG_CONFIG_JSON}")
                fi
                if [ -n "${STATSD_SERVICE_TYPE}" ]; then
                    EXTRA_CLI_FLAGS+=('--statsd-prefix' "${STATSD_SERVICE_TYPE}")
                fi

                echo 'Starting the swh-provenance RPC server'
                exec gunicorn --bind "0.0.0.0:${PORT}" \
                     --log-level "${SWH_LOG_LEVEL:-INFO}" \
                     "${EXTRA_CLI_FLAGS[@]}" \
                     --threads "${THREADS}" \
                     --workers "${WORKERS}" \
                     --timeout "${TIMEOUT}" \
                     --reload \
                     --config 'python:swh.core.api.gunicorn_config' \
                     'swh.provenance.api.server:make_app_from_configfile()'
              ;;
            "grpc")
                echo 'Starting the swh-provenance GRPC server'
                exec swh-provenance-grpc-serve --bind "0.0.0.0:${PORT}" \
                    --database "file://${PROVENANCE_PATH}" \
                    --graph "${GRAPH_PATH}" \
                    "${EXTRA_CLI_FLAGS[@]}" \
                ;;
            *)
                echo "Unknown provenance type <${PROVENANCE_TYPE}> (either rpc or gprc)"
                exit 1
        esac
esac
