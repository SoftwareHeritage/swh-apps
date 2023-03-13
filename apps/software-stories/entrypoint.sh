#!/bin/bash

set -e

case "$1" in
  "shell")
    shift
    echo "Running command $@"
    exec bash -i "$@"
    ;;
  *)
    exec serve -s build
    ;;
esac
