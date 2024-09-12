# Dockerfile

# Use an official lightweight base image
FROM alpine:latest

# Install curl to make HTTP requests
RUN apk --no-cache add curl bash

# Copy the health_check.sh script into the container
WORKDIR /app
COPY health_check.sh /app/health_check.sh

# Make the script executable
RUN chmod +x /app/health_check.sh

# Set the default command to run the script
CMD ["./health_check.sh"]
