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
        echo "swh-alter pod: running a tmux server"
        tmux set -g exit-empty off \; start

        trap "tmux kill-server" INT TERM EXIT

        while tmux list-sessions 2>/dev/null; do sleep 5; done
        echo "tmux server has exited, bailing"
        ;;
esac
