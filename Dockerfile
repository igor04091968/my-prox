FROM alpine:latest

# Install tinyproxy
RUN apk update && apk add --no-cache tinyproxy

# Copy custom config file
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf

# Expose the proxy port
EXPOSE 8888

# Run tinyproxy in the foreground
CMD ["tinyproxy", "-d"]
