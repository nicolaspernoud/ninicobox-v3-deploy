# Building the server

FROM golang as server-builder

WORKDIR /server

RUN apt-get update && \
    apt-get -y install libcap2-bin

ADD ninicobox-v3-server .
RUN go get -d ./... && \
    go test ./... && \
    CGO_ENABLED=0 go build

RUN setcap cap_net_bind_service=+ep ninicobox-v3-server

# Building the client

FROM node:12 as client-builder

WORKDIR /client

ADD ninicobox-v3-client .
RUN npm install npm@latest -g
RUN npm install && \
    npm run build && \
    npm run translate-and-patchsw

# Putting all together

FROM alpine

WORKDIR /app

COPY --from=server-builder /server/ninicobox-v3-server /app
COPY --from=server-builder /server/configs /app/configs
COPY --from=server-builder /server/data /app/data
COPY --from=server-builder /server/dev_certificates /app/dev_certificates
COPY --from=server-builder /server/ipgeodatabase /app/ipgeodatabase
COPY --from=client-builder /client/dist /app/web
COPY --from=client-builder /client/package.json /app/web

ENTRYPOINT [ "./ninicobox-v3-server"]
