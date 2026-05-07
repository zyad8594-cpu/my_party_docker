FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application files
COPY . .

# Expose port (default in index.js is 3000)
EXPOSE 3000

# Start command
CMD ["node", "index.js"]
