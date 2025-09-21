#!/bin/sh

# Start the DDNS update loop in the background
(
  while true; do
    echo "--- Running Cloudflare DDNS update ---"
    /app/cf-ddns.sh
    echo "--- Update finished. Sleeping for 5 minutes. ---"
    sleep 300
  done
) &

# Start tinyproxy in the foreground as the main process
echo "--- Starting tinyproxy ---"
exec tinyproxy -d
