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
        exit 0
        ;;
    *)
        if [ -z "${SWH_CONFIG_FILENAME}" ]; then
            echo "The SWH_CONFIG_FILENAME environment variable must be set"
            exit 1
        fi

        if [ ! -e "${SWH_CONFIG_FILENAME}" ]; then
            echo "The config file ${SWH_CONFIG_FILENAME} does not exist"
            exit 1
        fi

        # start the replayer
        echo "Starting the replayer..."
        exec swh storage replay
        ;;
esac
