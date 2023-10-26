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
      echo Starting the swh-objstorage API server
      exec gunicorn --bind 0.0.0.0:${PORT} \
          --log-level ${LOG_LEVEL} \
          --threads 1 \
          --workers ${WORKERS} \
          --reload \
          --timeout 3600 \
          --config 'python:swh.core.api.gunicorn_config' \
          'swh.objstorage.api.server:make_app_from_configfile()'
      ;;
esac
