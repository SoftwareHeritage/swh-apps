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
