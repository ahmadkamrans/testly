#!/bin/sh

export REPLACE_OS_VARS=true
export PUBLIC_HOSTNAME=`curl http://169.254.170.2/v2/metadata | jq -r ".Containers[0].Networks[0].IPv4Addresses[0]"`

echo "Hostname: $PUBLIC_HOSTNAME"

REPLACE_OS_VARS=true /app/release/bin/start_server foreground
