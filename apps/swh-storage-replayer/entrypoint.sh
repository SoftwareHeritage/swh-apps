#!/bin/bash

if [ -z "${SWH_CONFIG_FILENAME}" ]; then
  echo "The SWH_CONFIG_FILENAME" environment must be set
  exit 1
fi

if [ ! -e "${SWH_CONFIG_FILENAME}" ]; then
  echo "The config file ${SWH_CONFIG_FILENAME} does not exists"
  exit 1
fi

# start the replayer
echo "Starting the replayer..."
swh storage replay
