#!/bin/bash

set -e

source /srv/softwareheritage/utils/pyutils.sh
setup_pip

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
       --maxtasksperchild=${MAX_TASKS_PER_CHILD} \
       -Ofair --loglevel=${LOGLEVEL} \
       --without-gossip --without-mingle --without-heartbeat \
       --hostname "${SWH_WORKER_INSTANCE}@%h"
    ;;
esac
