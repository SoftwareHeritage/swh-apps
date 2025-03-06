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

        echo Starting the swh "${SWH_WORKER_INSTANCE}"
        #exec 
        ;;
esac
