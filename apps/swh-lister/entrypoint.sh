#!/bin/bash

set -e

case "$1" in
  "shell")
    shift
    echo "Running command $@"
    exec bash -i "$@"
    ;;
  *)
    echo Starting the swh Celery worker for ${SWH_WORKER_INSTANCE}
    exec python -m celery \
       --app=swh.scheduler.celery_backend.config.app \
       worker \
       --pool=prefork --events \
       --concurrency=${CONCURRENCY} \
       --max-tasks-per-child=${MAX_TASKS_PER_CHILD} \
       -Ofair \
       --loglevel=${SWH_LOG_LEVEL:-INFO} \
       --without-gossip --without-mingle --without-heartbeat \
       --hostname "${SWH_WORKER_INSTANCE}@%h"
    ;;
esac
