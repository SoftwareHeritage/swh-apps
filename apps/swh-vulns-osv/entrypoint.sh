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
    "create-report-processing-tasks")
        shift
        echo "Create report processing tasks in scheduler db"
        exec swh vulns osv create-report-processing-tasks
        ;;
    "compute-report-tasks")
        echo "Starting the swh Celery worker for ${SWH_WORKER_INSTANCE}"
        exec python -m celery \
             --app=swh.scheduler.celery_backend.config.app \
             worker \
             --pool=prefork \
             --concurrency=${CONCURRENCY} \
             --max-tasks-per-child=${MAX_TASKS_PER_CHILD} \
             -Ofair \
             --loglevel=${SWH_LOG_LEVEL:-INFO} \
             --without-gossip --without-mingle --without-heartbeat \
             --hostname "${SWH_WORKER_INSTANCE}@%h"
        ;;
    *)
        # The default behavior is to run the rpc server
        EXTRA_CLI_FLAGS=()
        if [ -n "${SWH_LOG_CONFIG_JSON}" ]; then
            EXTRA_CLI_FLAGS+=('--log-config-json' "${SWH_LOG_CONFIG_JSON}")
        fi
        if [ -n "${STATSD_HOST}" ] && [ -n "${STATSD_PORT}" ]; then
            EXTRA_CLI_FLAGS+=('--statsd-host' "${STATSD_HOST}:${STATSD_PORT}")
            EXTRA_CLI_FLAGS+=('--dogstatsd-tags' "pod:${HOSTNAME}")
        fi
        if [ -n "${STATSD_SERVICE_TYPE}" ]; then
            EXTRA_CLI_FLAGS+=('--statsd-prefix' "${STATSD_SERVICE_TYPE}")
        fi

        echo 'Starting the swh-vulns API server'
        exec gunicorn --bind "0.0.0.0:${PORT}" \
             --log-level "${SWH_LOG_LEVEL:-INFO}" \
             "${EXTRA_CLI_FLAGS[@]}" \
             --threads "${THREADS}" \
             --workers "${WORKERS}" \
             --timeout "${TIMEOUT}" \
             --config 'python:swh.core.api.gunicorn_config' \
             'swh.vulns.api.server:make_app_from_configfile()'
        ;;
esac
