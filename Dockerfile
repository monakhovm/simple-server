FROM golang:alpine AS builder
WORKDIR /app
COPY . .
RUN go test ./... && go build -o simple-server

FROM alpine:latest
WORKDIR /simple-server
COPY --from=builder /app/simple-server .
COPY ./public ./public
COPY ./templates ./templates
RUN ls -lah
CMD ["./simple-server"]

