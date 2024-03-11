#!/bin/bash

set -e

CLONE_DIR=/opt/swh/snippets

if [ ! -d $CLONE_DIR ]; then
    git clone --depth=1 https://gitlab.softwareheritage.org/swh/devel/snippets.git $CLONE_DIR
else
    pushd $CLONE_DIR
    git fetch
    git merge origin/master
    popd
fi

case "$1" in
  "shell")
    shift
    echo "Running command $@"
    exec bash -i "$@"
    ;;
  *)
    echo Starting Cassandra objects checker.
    exec $CLONE_DIR/sysadmin/cassandra_checks/get_journal_check_and_replay.py
    ;;
esac
