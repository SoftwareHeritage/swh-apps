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
    "refresh")
        echo "Start periodic save code now refresh statuses routine (in background)"
        exec sh -c 'date && django-admin refresh_savecodenow_statuses \
                      --settings=${DJANGO_SETTINGS_MODULE} 2>&1'
        ;;
    "sync-mailmaps")
        shift
        echo "django-admin sync-mailmaps routine"
        date
        exec sh -c "django-admin sync_mailmaps --perform '$@'"
        ;;
    *)
        echo "Starting the swh-web server"
        # run gunicorn workers as in production otherwise
        exec gunicorn --bind 0.0.0.0:${PORT} \
             --log-level ${SWH_LOG_LEVEL:-INFO} \
             --threads ${THREADS} \
             --workers ${WORKERS} \
             --timeout ${TIMEOUT} \
             --statsd-host=${STATSD_HOST}:${STATSD_PORT} \
             --statsd-prefix=${STATSD_SERVICE_TYPE} \
             --access-logfile '-' \
             --env DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE} \
             --config 'python:swh.web.gunicorn_config' \
             'django.core.wsgi:get_wsgi_application()'
esac
