#!/bin/bash

set -e

case "$1" in
  "shell")
    shift
    echo "Running command $@"
    exec bash -i "$@"
    ;;
  *)
    echo Starting Cassandra objects checker.
    exec python -m /opt/swh/snippets/sysadmin/cassandra_checks/get_journal_check_and_replay.py
    ;;
esac
