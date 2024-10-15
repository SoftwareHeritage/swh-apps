#!/bin/bash

set -e

case "${GRAPH_TYPE}" in
    "rpc")
        subcmd="rpc-serve -h 0.0.0.0 -p ${PORT}"
        if [ ! -z "${GRAPH_PATH}" ]; then
           subcmd+=" -g ${GRAPH_PATH}"
        fi
        ;;
    "grpc")
        subcmd="grpc-serve -g ${GRAPH_PATH} -p ${PORT}"
        ;;
    *)
        echo "Unknown graph type <$GRAPH_TYPE> (either rpc or gprc)"
        exit 1
esac

echo "Starting the swh-graph ${GRAPH_TYPE} server"
cmd="swh graph -C ${SWH_CONFIG_FILENAME} $subcmd"
echo $cmd
$cmd
