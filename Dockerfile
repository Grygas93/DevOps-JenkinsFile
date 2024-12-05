# Use official Node.js image as base
FROM node:16

# Set working directory
WORKDIR /app

# Copy server.js into the container
COPY server.js .

# Expose port 8080
EXPOSE 8080

# Start the server
CMD ["node", "server.js"]
