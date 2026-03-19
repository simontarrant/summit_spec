.PHONY: dev build test docker-build docker-run clean

dev:
	go run ./cmd/api

build:
	go build -o bin/api ./cmd/api

test:
	go test ./...

docker-build:
	docker build -t summit-spec-api .

docker-run:
	docker run --rm -p 8080:8080 --env-file .env summit-spec-api

clean:
	rm -rf bin/
