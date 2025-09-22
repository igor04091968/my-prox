FROM alpine:latest

# Install tinyproxy and dependencies for ddns script and chisel
RUN apk update && apk add --no-cache tinyproxy curl jq bash gzip

# Download and install chisel
RUN curl -sL https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_amd64.gz | gunzip > /usr/local/bin/chisel && \
    chmod +x /usr/local/bin/chisel

# Copy config and scripts
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY cf-ddns.sh /app/cf-ddns.sh
COPY entrypoint.sh /app/entrypoint.sh

# Make scripts executable
RUN chmod +x /app/cf-ddns.sh && chmod +x /app/entrypoint.sh

# Create directory for pid file and set permissions
RUN mkdir -p /run/tinyproxy && chown -R tinyproxy:tinyproxy /run/tinyproxy

# Expose the proxy port
EXPOSE 80

# Run the entrypoint script
CMD ["/app/entrypoint.sh"]
