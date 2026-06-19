#!/bin/bash

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
        echo "[ -f ~/venv/bin/activate ] && source ~/venv/bin/activate" >> ~/.bashrc
        echo "Benchmarking purpose pod: connect to it and do what you will!"
        while sleep infinity; do :; done
        ;;
esac
