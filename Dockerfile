FROM node:18-slim

WORKDIR /app

# Install cron and jq for the DDNS script
RUN apt-get update && apt-get install -y cron jq && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm install

COPY . .

# Setup cron job if my-cron exists
RUN if [ -f /app/my-cron ]; then chmod 0644 /app/my-cron && crontab /app/my-cron; fi

# Make scripts executable
RUN chmod +x /app/entrypoint.sh
RUN if [ -f /app/cf-ddns.sh ]; then chmod +x /app/cf-ddns.sh; fi

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]