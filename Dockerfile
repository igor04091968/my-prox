FROM alpine:latest

# Install tinyproxy and dependencies for ddns script
RUN apk update && apk add --no-cache tinyproxy curl jq

# Copy config and scripts
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY cf-ddns.sh /app/cf-ddns.sh
COPY entrypoint.sh /app/entrypoint.sh

# Make scripts executable
RUN chmod +x /app/cf-ddns.sh && chmod +x /app/entrypoint.sh

# Create directory for pid file and set permissions
RUN mkdir -p /run/tinyproxy && chown -R tinyproxy:tinyproxy /run/tinyproxy

# Expose the proxy port
EXPOSE 8888

# Run the entrypoint script
CMD ["/app/entrypoint.sh"]
