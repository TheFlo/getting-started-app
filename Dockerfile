# syntax=docker/dockerfile:1.0
FROM node:26-alpine
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install --omit=dev

COPY . .

CMD ["node", "src/index.js"]
EXPOSE 3000
