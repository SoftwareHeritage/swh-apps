#!/bin/bash

set -e

case "$1" in
"shell")
  exec bash -i
  ;;
*)
  echo Starting the swh-graphql API server

  exec gunicorn --bind "0.0.0.0:${PORT}" \
    --threads "${THREADS}" \
    --workers "${WORKERS}" \
    --log-level "${LOG_LEVEL}" \
    --timeout "${TIMEOUT}" \
    --config 'python:swh.core.api.gunicorn_config' \
    'swh.graphql.server:make_app_from_configfile()'
  ;;
esac
