#!/bin/bash

set -e

echo "swh-alter pod: running a tmux server"
exec tmux -D
