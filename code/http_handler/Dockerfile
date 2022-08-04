FROM golang:1.16 AS build
WORKDIR /go/src/app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -v -o app ./

FROM alpine:latest
WORKDIR /root/
COPY --from=build /go/src/app/app .
CMD ["./app"]
