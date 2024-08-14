#!/bin/bash

set -e

case "$1" in
    "shell")
      exec bash -i
      ;;
    "swh")
        shift
        echo "Running swh command $@"
        exec swh $@
        ;;
    "create-object-reference-partitions"|"create-object-references-partitions")
        echo "Running swh storage create-object-reference-partitions $(date +%Y-%m-%d) $(date -d '+1 month' +%Y-%m-%d)"
        exec swh storage create-object-reference-partitions "$(date +%Y-%m-%d)" "$(date -d '+1 month' +%Y-%m-%d)"
        ;;
    *)
        EXTRA_CLI_FLAGS=""
        if [ ! -z "${SWH_LOG_CONFIG_JSON}" ]; then
            EXTRA_CLI_FLAGS="--log-config-json ${SWH_LOG_CONFIG_JSON}"
        fi
        echo Starting the swh-storage API server
        exec gunicorn --bind 0.0.0.0:${PORT} \
             --log-level ${SWH_LOG_LEVEL:-INFO} \
             $EXTRA_CLI_FLAGS \
             --threads ${THREADS} \
             --workers ${WORKERS} \
             --timeout ${TIMEOUT} \
             --statsd-host=${STATSD_HOST}:${STATSD_PORT} \
             --statsd-prefix=${STATSD_SERVICE_TYPE} \
             --config 'python:swh.core.api.gunicorn_config' \
             'swh.storage.api.server:make_app_from_configfile()'
        ;;
esac
