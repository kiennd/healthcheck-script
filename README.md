# Health Check Script

This repository contains a Bash script that monitors the health of multiple services by making `GET` requests to specified URLs. If any of the services do not return an HTTP 200 status code, or if the request times out after 10 seconds, the script sends an alert message to a designated Telegram group using a Telegram bot. The alert message format and mentions can be customized via environment variables.

## Features

- Monitor multiple URLs (endpoints) in a single script.
- Sends a customizable alert message if a service does not return an HTTP 200 status code.
- Supports configurable Telegram mentions.
- Logs each health check's result to the console for easy monitoring.
- Runs inside a Docker container for portability and ease of deployment.
- Can be automatically restarted using Docker Compose.

## Requirements

- Bash
- `curl` (pre-installed on most Unix-based systems)
- Docker and Docker Compose
- Telegram Bot API token and Group Chat ID

## Setup

### 1. Clone or Download the Repository

```bash
git clone https://github.com/your-repo/health-check-script.git
cd health-check-script
```

### 2. Create a `.env` File

Create a `.env` file in the root of the project directory with the following content:

```bash
# .env file

# The URLs to be checked (space-separated)
URLS="https://httpstat.us/500 https://httpstat.us/200 https://httpstat.us/404"

# Service Names (in the same order as URLs)
SERVICE_NAMES="Service 500 Service 200 Service 404"

# Telegram Bot API token
TELEGRAM_BOT_TOKEN="your-telegram-bot-token"

# Telegram Group Chat ID
TELEGRAM_GROUP_CHAT_ID="your-telegram-group-chat-id"

# Alert message format with placeholders
# Available placeholders: {service}, {url}, {status}, {mention}
ALERT_MESSAGE_FORMAT="⚠️ Service '{service}' at {url} is down! Status: {status}. {mention}"

# Mention to include in the alert (e.g., @admin)
ALERT_MENTION="@admin"
```

- **URLS**: A space-separated list of URLs to monitor.
- **SERVICE_NAMES**: Corresponding names for the services, in the same order as the URLs.
- **ALERT_MESSAGE_FORMAT**: Customize the alert message using placeholders:
  - `{service}`: The service name.
  - `{url}`: The URL being monitored.
  - `{status}`: The HTTP status code returned by the service.
  - `{mention}`: Any mention (e.g., `@username`) you want to include in the message.
- **ALERT_MENTION**: The Telegram username (e.g., `@admin`) or user ID to be mentioned in the alert.

### 3. Run with Docker Compose

A `docker-compose.yml` file is included to easily run the script inside a Docker container.

#### Build the Docker Image

```bash
docker-compose build
```

#### Run the Container

```bash
docker-compose up -d
```

This will start the container in detached mode. The health check will run every 5 seconds, and each result will be logged to the console.

### 4. Monitor the Logs

To view the real-time logs from the running container:

```bash
docker-compose logs -f
```

This will display the logs of each health check, including HTTP responses and errors (if any).

### 5. Stop the Service

To stop and remove the running container:

```bash
docker-compose down
```

## Example `.env` for Multiple Endpoints and Mentions

Here’s an example `.env` file for monitoring multiple endpoints and mentioning a Telegram user:

```bash
URLS="https://httpstat.us/500 https://httpstat.us/200 https://httpstat.us/404"
SERVICE_NAMES="Service 500 Service 200 Service 404"
TELEGRAM_BOT_TOKEN="your-telegram-bot-token"
TELEGRAM_GROUP_CHAT_ID="your-telegram-group-chat-id"
ALERT_MESSAGE_FORMAT="⚠️ Service '{service}' at {url} is down! Status: {status}. {mention}"
ALERT_MENTION="@admin"
```

In this setup:
- The script checks three different endpoints.
- If any of them fail (returning anything other than HTTP 200), it sends a customized alert message to the Telegram group, mentioning `@admin`.

## Example Alert Message

If a service returns an error, the alert message sent to the Telegram group will look like this:

```
⚠️ Service 'Service 500' at https://httpstat.us/500 is down! Status: 500. @admin
```

## Script Behavior

- The script sends a `GET` request to each specified URL.
- If the HTTP response is not `200`, or if the request times out (after 10 seconds), it sends an alert message to the specified Telegram group.
- The message includes the service name, URL, HTTP status code, and a customizable mention.
- Logs each status check result to the console for easy monitoring.

### Cron-Like Behavior

The `health_check.sh` script runs in an infinite loop, with a 5-second pause between each check. This allows it to continuously monitor the services.

## Project Structure

Your project should look like this:

```
/project-root
│
├── .env
├── Dockerfile
├── docker-compose.yml
└── health_check.sh
```

## License

This project is licensed under the MIT License.
