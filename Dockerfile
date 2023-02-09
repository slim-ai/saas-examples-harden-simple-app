FROM node:17

USER node

WORKDIR /service

COPY --chown=node . .

RUN yarn install

EXPOSE 8080

ENTRYPOINT [ "node", "server.js" ]
