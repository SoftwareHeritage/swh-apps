#!/bin/bash

set -e

case "$1" in
    'shell')
        shift
        if (( $# == 0)); then
            exec bash -i
        else
            "$@"
        fi
        ;;
    'refresh')
        echo 'Start periodic save code now refresh statuses routine (in background)'
        exec sh -c 'date && django-admin refresh_savecodenow_statuses \
                      --settings=${DJANGO_SETTINGS_MODULE} 2>&1'
        ;;
    'sync-mailmaps')
        echo Deprecated use django-admin instead
        shift
        echo 'django-admin sync-mailmaps routine'
        date
        exec sh -c "django-admin sync_mailmaps --perform '$@'"
        ;;
    'django-admin')
        shift
        COMMAND=$1
        shift
        echo "django-admin ${COMMAND} routine"
        date
        set -x
        exec sh -c "django-admin ${COMMAND} $*"
        ;;
    *)
        # run gunicorn workers with production configuration
        EXTRA_CLI_FLAGS=()
        if [ -n "${SWH_LOG_CONFIG_JSON}" ]; then
            EXTRA_CLI_FLAGS+=('--log-config-json' "${SWH_LOG_CONFIG_JSON}")
        fi
        if [ -n "${STATSD_HOST}" -a -n "${STATSD_PORT}" ]; then
            EXTRA_CLI_FLAGS+=('--statsd-host' "${STATSD_HOST}:${STATSD_PORT}")
        fi
        if [ -n "${STATSD_SERVICE_TYPE}" ]; then
            EXTRA_CLI_FLAGS+=('--statsd-prefix' "${STATSD_SERVICE_TYPE}")
        fi
        if [ -n "${SWH_DEV_MODE}" ]; then
            EXTRA_CLI_FLAGS+=("--reload")
        fi

        echo 'Starting swh web server'
        exec gunicorn --bind "0.0.0.0:${PORT}" \
             --log-level "${SWH_LOG_LEVEL:-INFO}" \
             "${EXTRA_CLI_FLAGS[@]}" \
             --threads "${THREADS}" \
             --workers "${WORKERS}" \
             --timeout "${TIMEOUT}" \
             --access-logfile '-' \
             --env DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE} \
             --config 'python:swh.web.gunicorn_config' \
             'django.core.wsgi:get_wsgi_application()'
esac
