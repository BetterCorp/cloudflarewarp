.PHONY: lint test vendor clean

export GO111MODULE=on

default: lint test

lint:
	golangci-lint run

test:
	go test -race -coverprofile=coverage.txt -covermode=atomic ./...

yaegi_test:
	yaegi test .
