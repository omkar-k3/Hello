FROM node:12

# Create app directory
WORKDIR /usr/src/app

COPY package.json ./
COPY package-lock.json ./ 

RUN npm install

# Bundle app source
COPY . .

EXPOSE 8080

CMD [ "node", "server.js" ]
