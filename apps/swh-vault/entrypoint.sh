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
    *)
      echo Starting the swh-vault API server
      exec gunicorn --bind 0.0.0.0:${PORT} \
           --log-level ${SWH_LOG_LEVEL:-INFO} \
           --threads ${THREADS} \
           --workers ${WORKERS} \
           --timeout ${TIMEOUT} \
           --config 'python:swh.core.api.gunicorn_config' \
           'swh.vault.api.server:make_app_from_configfile()'
      ;;
esac
