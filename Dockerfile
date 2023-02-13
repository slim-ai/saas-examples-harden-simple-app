FROM node:18

WORKDIR /service

COPY --chown=node:node . .

RUN chown -R node:node /service

RUN yarn install

EXPOSE 8080

USER node

ENTRYPOINT [ "node", "server.js" ]
