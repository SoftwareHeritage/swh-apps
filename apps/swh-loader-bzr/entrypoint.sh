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
    *)
        # If a pod is killed by the OOM killer, there can remain previous
        # workdir as the ephemeral volumes are not recreated
        echo "Cleaning /tmp..."
        rm -rf /tmp/*
        echo Starting the swh Celery worker for ${SWH_WORKER_INSTANCE}
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
esac
