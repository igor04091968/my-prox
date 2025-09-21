FROM alpine:latest

# Install tinyproxy
RUN apk update && apk add --no-cache tinyproxy

# Copy custom config file
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf

# Create directory for pid file and set permissions
RUN mkdir -p /run/tinyproxy && chown -R tinyproxy:tinyproxy /run/tinyproxy

# Expose the proxy port
EXPOSE 8888

# Run tinyproxy in the foreground
CMD ["tinyproxy", "-d"]
