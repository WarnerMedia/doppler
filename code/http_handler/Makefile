include ./config/dev2.us-east-1.env
export

PACKAGES := $(shell go list ./...)
BUILD_VERSION := $(shell git describe --tags)

all: help

.PHONY: help
help: Makefile
	@echo
	@echo " Choose a make command to run"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## vet: vet code
.PHONY: vet
vet:
	go vet ./...

## lint: check fmt linter
.PHONY: lint
lint:
	gofmt -l -d ./..
	test -z $(gofmt -l ./..)

## fmt: fmt code
.PHONY: fmt
fmt:
	go fmt ./...

## test: run unit tests
.PHONY: test
test:
	go test -race -cover ./...

## integration: run integration tests
.PHONY: integration
integration:
	go test -race -cover $(PACKAGES) -integrationTest

## loadtest: run load test
.PHONY: loadtest
loadtest:
	cp ~/.aws/credentials .
	toast invoke

## build: build a binary
.PHONY: build
build: test
	go build -v

## deploy: build code into a container and deploy it to the cloud dev environment
.PHONY: deploy
deploy: build
	./deploy.sh

## start: build and start local web server
.PHONY: start
start: build
	clear
	@echo ""
	AWS_PROFILE= ./http-handler

## build-docker: build app in docker
.PHONY: build-docker
build-docker: build
	docker-compose build

## start-docker: build and start local web server in docker
.PHONY: start-docker
start-docker: build-docker
	docker-compose up
