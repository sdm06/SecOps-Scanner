FROM node:14-alpine

RUN apk add --no-cache curl

WORKDIR /usr/src/app
COPY package.json ./
RUN npm install
COPY . .

EXPOSE 3000
CMD ["node", "server.js"]
