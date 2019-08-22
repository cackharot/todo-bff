STACK=stack
DC=docker-compose
CWD=$(shell pwd)
APP_PATH=$(shell stack exec which todo-bff-exe)
APP_BIN=$(subst $(CWD)/,,$(APP_PATH))

## Build binary and docker images
build:
	$(STACK) build
	@echo "Binary file at $(APP_BIN)"
	@BINARY_PATH=${APP_BIN} $(DC) build

test:
	$(STACK) test

run:
	@docker-compose up -d

.PHONY: clean test

clean:
	$(STACK) clean
