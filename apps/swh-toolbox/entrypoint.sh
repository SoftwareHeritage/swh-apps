#!/bin/bash

set -e

case "$1" in
  "shell")
      shift
      echo "Running command $@"
      exec bash -i "$@"
    ;;
  *)
      echo "Registering new swh scheduler tasks"
      exec python -m swh scheduler \
           --config-file ${SWH_CONFIG_FILENAME} \
           task-type register
    ;;
esac
