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
        EXTRA_CLI_FLAGS=""
        if [ ! -z "${SWH_LOG_CONFIG_JSON}" ]; then
            EXTRA_CLI_FLAGS="--log-config-json ${SWH_LOG_CONFIG_JSON}"
        fi
        echo Starting the swh-counters API server
        exec gunicorn --bind 0.0.0.0:${PORT} \
             --log-level ${SWH_LOG_LEVEL:-INFO} \
             ${EXTRA_CLI_FLAGS} \
             --threads ${THREADS} \
             --workers ${WORKERS} \
             --timeout ${TIMEOUT} \
             --statsd-host=${STATSD_HOST}:${STATSD_PORT} \
             --statsd-prefix=${STATSD_SERVICE_TYPE} \
             --reload \
             --config 'python:swh.core.api.gunicorn_config' \
             'swh.counters.api.server:make_app_from_configfile()'
esac
