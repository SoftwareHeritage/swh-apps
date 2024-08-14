#!/bin/bash

set -e

case "$1" in
    "shell")
        exec bash -i
        ;;
    *)
        echo Starting the swh-graphql API server
        exec gunicorn --bind 0.0.0.0:${PORT} \
             --log-level ${SWH_LOG_LEVEL:-INFO} \
             --threads ${THREADS} \
             --workers ${WORKERS} \
             --timeout ${TIMEOUT} \
             --statsd-host=${STATSD_HOST}:${STATSD_PORT} \
             --statsd-prefix=${STATSD_SERVICE_TYPE} \
             --config 'python:swh.graphql.gunicorn_config' \
             --worker-class 'uvicorn.workers.UvicornWorker' \
             'swh.graphql.server:make_app_from_configfile()'
        ;;
esac
