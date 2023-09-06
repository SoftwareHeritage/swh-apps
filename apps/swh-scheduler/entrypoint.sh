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
        echo Starting the swh-scheduler API server
        exec gunicorn --bind 0.0.0.0:5008 \
            --log-level ${LOG_LEVEL} \
            --threads ${THREADS} \
            --workers ${WORKERS} \
            --reload \
            --timeout ${TIMEOUT} \
            --config 'python:swh.core.api.gunicorn_config' \
            'swh.scheduler.api.server:make_app_from_configfile()'
esac
