FROM node:17
ADD service /service
WORKDIR /service
RUN yarn install
EXPOSE 8080
ENTRYPOINT [ "node", "server.js" ]

