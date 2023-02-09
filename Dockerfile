FROM node:17

USER node

ADD service /service

WORKDIR /service

RUN yarn install

EXPOSE 8080

ENTRYPOINT [ "node", "server.js" ]
