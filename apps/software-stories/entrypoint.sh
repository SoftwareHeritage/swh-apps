#!/bin/bash

set -e

case "$1" in
"shell")
    shift
    echo "Running command $@"
    exec bash -i "$@"
    ;;
*)
    exec /opt/swh/swh-stories/node_modules/.bin/vite --host --port 3000
    ;;
esac
