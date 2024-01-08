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
        exec swh --log-level ${LOG_LEVEL} storage create-object-reference-partitions "$(date +%Y-%m-%d)" "$(date -d '+1 month' +%Y-%m-%d)"
        ;;
    *)
      echo Starting the swh-storage API server
      exec gunicorn --bind 0.0.0.0:${PORT} \
           --threads ${THREADS} \
           --workers ${WORKERS} \
           --log-level ${LOG_LEVEL} \
           --timeout ${TIMEOUT} \
           --config 'python:swh.core.api.gunicorn_config' \
           'swh.storage.api.server:make_app_from_configfile()'
      ;;
esac
