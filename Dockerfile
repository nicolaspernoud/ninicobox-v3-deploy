# Building the server

FROM          golang:alpine as server-builder

RUN           apk update && apk upgrade && \
              apk add --no-cache bash git openssh
RUN           go get github.com/nicolaspernoud/ninicobox-v3-server
RUN           cd /go/src/github.com/nicolaspernoud/ninicobox-v3-server && go get -d -v && go build

# Building the client

FROM          node:8 as client-builder

WORKDIR       /src

RUN           git clone https://github.com/nicolaspernoud/ninicobox-v3-client
RUN           npm install npm@latest -g
RUN           cd ninicobox-v3-client && \
              npm install && \
              npm run build && \
              npm run translate-and-patchsw

# Putting all together

FROM          alpine

WORKDIR       /app

RUN           apk update && apk add ca-certificates libcap

COPY          --from=server-builder /go/src/github.com/nicolaspernoud/ninicobox-v3-server /app/
COPY          --from=client-builder /src/ninicobox-v3-client/dist/ /app/client
COPY          --from=client-builder /src/ninicobox-v3-client/package.json /app/client/

RUN           setcap cap_net_bind_service=+ep ninicobox-v3-server

ENTRYPOINT    [ "./ninicobox-v3-server"]