FROM node:20-alpine

# Install build tools for native modules
RUN apk add --no-cache python3 make g++

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

EXPOSE 1337

CMD ["npm", "start"]
