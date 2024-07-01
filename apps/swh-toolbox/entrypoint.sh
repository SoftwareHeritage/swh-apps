#!/bin/bash

set -e

MSG='USAGE_MSG="\e[1;31mSWH_CONFIG_FILENAME variable is not set!\n\n
This variable must be defined according to your use case (e.g. .\n
scheduler, storage, vault, ...). You must define it by yourself.\e[m\n\n
\e[0;33mFor example, use one of the following:\e[m\n"'

echo $MSG >> .bashrc
echo 'echo -e $USAGE_MSG' >> .bashrc
echo "find /etc/swh/ -type f -iname '*.yml' | xargs -i echo 'export SWH_CONFIG_FILENAME={}'" >> .bashrc

echo "Administration purpose pod: connect to it and do what you will!"
while sleep infinity; do :; done
