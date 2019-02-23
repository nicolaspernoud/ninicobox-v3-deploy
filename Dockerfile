# Building the server

FROM          golang:alpine as server-builder

WORKDIR       /server

RUN           apk update && apk upgrade && \
              apk add --no-cache bash git openssh build-base
ADD           ninicobox-v3-server .
RUN           go get -d ./... && \
              go test ./... && \
              go build

# Building the client

FROM          node:8 as client-builder

WORKDIR       /client

ADD           ninicobox-v3-client .
RUN           npm install npm@latest -g
RUN           npm install && \
              npm run build && \
              npm run translate-and-patchsw

# Putting all together

FROM          alpine

WORKDIR       /app

RUN           apk update && apk add ca-certificates libcap

COPY          --from=server-builder /server/server /app
COPY          --from=server-builder /server/configs /app/configs
COPY          --from=server-builder /server/data /app/data
COPY          --from=server-builder /server/dev_certificates /app/dev_certificates
COPY          --from=server-builder /server/ipgeodatabase /app/ipgeodatabase
COPY          --from=client-builder /client/dist /app/web
COPY          --from=client-builder /client/package.json /app/web

RUN           setcap cap_net_bind_service=+ep server

ENTRYPOINT    [ "./server"]