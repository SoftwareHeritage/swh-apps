#!/bin/bash

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
        exec swh "$@"
        ;;
    *)
        echo Unknown command $@
        exit 1
esac
