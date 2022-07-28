.PHONY: lint test vendor clean

export GO111MODULE=on

default: lint test

lint:
	golangci-lint run

test_actual: 
	cd .test-instance; bash test.sh

test:
	go test -race -coverprofile=coverage.txt -covermode=atomic ./*_test.go

yaegi_test:
	yaegi test .
