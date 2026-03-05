#!/bin/bash

if [ -n "$KAFKABACKUP_SSH_HOST_KEYS" ]; then
    echo "$KAFKABACKUP_SSH_HOST_KEYS" >> ~/.ssh/known_hosts
fi

kafkabackup "$@"
