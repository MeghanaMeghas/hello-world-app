# Use Node.js image from DockerHub
FROM node:14

# Create and set the working directory
WORKDIR /usr/src/app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy all the source code into the container
COPY . .

# Expose the port the app runs on
EXPOSE 8080

# Run the app
CMD ["node", "app.js"]
