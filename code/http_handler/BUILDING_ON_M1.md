# How to deploy this code on an M1 Mac

I bought an M1 Mac Mini awhile back and finally got around to trying to get our deployments working and ran into issues since it's an arm64 and our containers are built as x86-64.  Below is what I needed to do to get this to deploy successfully to fargate(which wasn't too bad).  

## In your Dockerfile

Convert from:

```
FROM golang:1.16 AS build
WORKDIR /go/src/app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -v -o app .

FROM alpine:latest
WORKDIR /root/
COPY --from=build /go/src/app/app .
CMD ["./app"]
```

to: 

```
FROM --platform=linux/x86-64 golang:1.16 AS build
WORKDIR /go/src/app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -v -o app .

FROM --platform=linux/x86-64 alpine:latest
WORKDIR /root/
COPY --from=build /go/src/app/app .
CMD ["./app"]
```
