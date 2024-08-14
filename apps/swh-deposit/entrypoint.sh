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
             --log-level ${SWH_LOG_LEVEL:-INFO} \
             --threads ${THREADS} \
             --workers ${WORKERS} \
             --timeout ${TIMEOUT} \
             --statsd-host=${STATSD_HOST}:${STATSD_PORT} \
             --statsd-prefix=${STATSD_SERVICE_TYPE} \
             --reload \
             --env DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE} \
             --config 'python:swh.core.api.gunicorn_config' \
             'django.core.wsgi:get_wsgi_application()'
esac
