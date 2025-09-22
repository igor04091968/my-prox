#!/bin/sh

# Start cron daemon in the background if my-cron exists
if [ -f /etc/cron.d/my-cron ]; then
  cron
fi

# Start the proxy server in the foreground
echo "Starting NPM proxy server..."
exec npm start