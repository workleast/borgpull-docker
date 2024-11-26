#!/bin/sh
# start crond
crond -l 2 -f
echo "Borgpull started. Waiting for commands..."
