#!/bin/bash

# Function to send an alert message to Telegram
send_alert() {
  local message="$1"
  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
  -d chat_id="$TELEGRAM_GROUP_CHAT_ID" \
  -d text="$message"
}

# Split URLs and Service Names into arrays
IFS=' ' read -r -a url_array <<< "$URLS"
IFS=' ' read -r -a service_array <<< "$SERVICE_NAMES"

# State variables to track the previous status of each service
declare -A service_warning_sent
declare -A service_agent_sent

# Infinite loop to continuously check services
while true; do
  # Loop through each URL
  for index in "${!url_array[@]}"; do
    url=${url_array[$index]}
    service_name=${service_array[$index]}

    # Ensure service_name is not empty
    if [ -z "$service_name" ]; then
      service_name="Unknown Service"
    fi

    # Perform GET request to the URL with a timeout of 10 seconds
    HTTP_RESPONSE=$(curl --write-out "%{http_code}" --silent --output /dev/null --max-time 10 "$url")

    # Log the HTTP response status
    echo "$(date): Checked service '$service_name' at $url. HTTP Status: $HTTP_RESPONSE"

    # Check if the response is 500 (Critical)
    if [ "$HTTP_RESPONSE" -eq 500 ]; then
      # Critical (Agent) Alert if service returns 500
      if [ "${service_agent_sent[$service_name]}" != true ]; then
        MESSAGE=$(echo "$ALERT_ERROR_MESSAGE_FORMAT" | sed "s|{service}|$service_name|g" | sed "s|{url}|$url|g" | sed "s|{status}|$HTTP_RESPONSE|g" | sed "s|{mention}|$ALERT_MENTION|g")
        send_alert "$MESSAGE"
        service_agent_sent[$service_name]=true
        service_warning_sent[$service_name]=false
      fi
    # Check if the response is any non-200 status
    elif [ "$HTTP_RESPONSE" -ne 200 ]; then
      # Warning Alert for other non-200 status codes
      if [ "${service_warning_sent[$service_name]}" != true ]; then
        MESSAGE=$(echo "$ALERT_ERROR_MESSAGE_FORMAT" | sed "s|{service}|$service_name|g" | sed "s|{url}|$url|g" | sed "s|{status}|$HTTP_RESPONSE|g" | sed "s|{mention}|$ALERT_MENTION|g")
        send_alert "$MESSAGE"
        service_warning_sent[$service_name]=true
        service_agent_sent[$service_name]=false
      fi
    else
      # Good Alert if service is back up (HTTP 200)
      if [ "${service_warning_sent[$service_name]}" = true ] || [ "${service_agent_sent[$service_name]}" = true ]; then
        MESSAGE=$(echo "$ALERT_NORMAL_MESSAGE_FORMAT" | sed "s|{service}|$service_name|g" | sed "s|{url}|$url|g" | sed "s|{status}|200|g" | sed "s|{mention}|$ALERT_MENTION|g")
        send_alert "$MESSAGE"
        service_warning_sent[$service_name]=false
        service_agent_sent[$service_name]=false
      fi
    fi
  done

  # Sleep for 5 seconds before the next round of checks
  sleep 5
done
