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
        echo Starting the swh-deposit API server
        exec gunicorn --bind 0.0.0.0:${PORT} \
            --log-level ${LOG_LEVEL} \
            --threads ${THREADS} \
            --workers ${WORKERS} \
            --reload \
            --timeout ${TIMEOUT} \
            --env DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE} \
            --config 'python:swh.core.api.gunicorn_config' \
            'django.core.wsgi:get_wsgi_application()'
esac
