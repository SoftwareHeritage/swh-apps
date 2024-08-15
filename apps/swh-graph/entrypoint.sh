#!/bin/bash

set -e

case "${GRAPH_TYPE}" in
    "rpc")
        echo Starting the swh-graph rpc server
        swh \
            graph \
            -C ${SWH_CONFIG_FILENAME} \
            rpc-serve \
            -g ${GRAPH_PATH} \
            -h 0.0.0.0 \
            -p ${PORT}
        ;;
    "grpc")
        echo Starting the swh-graph grpc server
        swh \
            graph \
            -C ${SWH_CONFIG_FILENAME} \
            grpc-serve \
            -g ${GRAPH_PATH} \
            -p ${PORT}
        ;;
    *)
        echo "Unknown graph type <$GRAPH_TYPE> (can only be one of rpc or gprc)"
        exit 1
esac
