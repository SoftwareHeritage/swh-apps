#!/bin/bash

set -e

case "$1" in
    "shell")
        exec bash -i
        ;;
    "refresh")
        echo "Start periodic save code now refresh statuses routine (in background)"
        exec sh -c 'date && django-admin refresh_savecodenow_statuses \
                      --settings=${DJANGO_SETTINGS_MODULE} 2>&1'
        ;;
    "cron")
        echo "Start periodic save code now refresh statuses routine (in background)"
        exec sh -c 'trap exit TERM INT; while :; do
        (date && django-admin refresh_savecodenow_statuses \
                  --settings=${DJANGO_SETTINGS_MODULE} 2>&1)
        sleep 15 &
        wait ${!}
        done'
        ;;

     *)
        echo "Starting the swh-web server"
        # run gunicorn workers as in production otherwise
        exec gunicorn \
            --bind 0.0.0.0:${PORT} \
            --threads ${THREADS} \
            --workers ${WORKERS} \
            --timeout ${TIMEOUT} \
            --access-logfile '-' \
            --env DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE} \
            --config 'python:swh.web.gunicorn_config' \
            'django.core.wsgi:get_wsgi_application()'
esac
