# Building the server

FROM          golang:alpine as server-builder

WORKDIR       /go/src

RUN           apk update && apk upgrade && \
              apk add --no-cache bash git openssh
ADD           ninicobox-v3-server github.com/nicolaspernoud/ninicobox-v3-server
RUN           cd github.com/nicolaspernoud/ninicobox-v3-server && go get -d -v && go build

# Building the client

FROM          node:8 as client-builder

WORKDIR       /src

ADD           ninicobox-v3-client .
RUN           npm install npm@latest -g
RUN           npm install && \
              npm run build && \
              npm run translate-and-patchsw

# Putting all together

FROM          alpine

WORKDIR       /app

RUN           apk update && apk add ca-certificates libcap

COPY          --from=server-builder /go/src/github.com/nicolaspernoud/ninicobox-v3-server /app
COPY          --from=client-builder /src/dist /app/client
COPY          --from=client-builder /src/package.json /app/client

RUN           setcap cap_net_bind_service=+ep ninicobox-v3-server

ENTRYPOINT    [ "./ninicobox-v3-server"]