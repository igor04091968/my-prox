#!/bin/sh

# Start the DDNS update loop in the background
(
  while true; do
    echo "--- Running Cloudflare DDNS update ---"
    /app/cf-ddns.sh
    echo "--- DDNS update finished. Sleeping for 5 minutes. ---"
    sleep 300
  done
) &

# Start the Chisel client reverse tunnel in a loop
(
  while true; do
    echo "--- Starting Chisel client ---"
    chisel client vds1.iri1968.dpdns.org:8080 R:8282:localhost:80
    echo "--- Chisel client disconnected. Reconnecting in 5 seconds. ---"
    sleep 5
  done
) &

# Start tinyproxy in the foreground as the main process
echo "--- Starting tinyproxy ---"
exec tinyproxy -d
