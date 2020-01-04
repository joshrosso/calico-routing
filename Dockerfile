FROM alpine:3.11.2

RUN apk update
RUN apk add curl wget bash ca-certificates
