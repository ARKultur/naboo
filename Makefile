# Build configuration
# -------------------

APP_NAME = `grep -Eo 'app: :\w*' mix.exs | cut -d ':' -f 3`
APP_VERSION = `grep -Eo 'version: "[0-9\.]*"' mix.exs | cut -d '"' -f 2`
GIT_REVISION = `git rev-parse HEAD`
DOCKER_IMAGE_TAG ?= $(APP_VERSION)
DOCKER_LOCAL_IMAGE = $(APP_NAME):$(DOCKER_IMAGE_TAG)

# Introspection targets
# ---------------------

.PHONY: help
help: header targets

.PHONY: header
header:
	@echo "\033[34mEnvironment\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@printf "\033[33m%-23s\033[0m" "APP_NAME"
	@printf "\033[35m%s\033[0m" $(APP_NAME)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "APP_VERSION"
	@printf "\033[35m%s\033[0m" $(APP_VERSION)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "GIT_REVISION"
	@printf "\033[35m%s\033[0m" $(GIT_REVISION)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "DOCKER_IMAGE_TAG"
	@printf "\033[35m%s\033[0m" $(DOCKER_IMAGE_TAG)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "DOCKER_LOCAL_IMAGE"
	@printf "\033[35m%s\033[0m" $(DOCKER_LOCAL_IMAGE)
	@echo "\n"

.PHONY: targets
targets:
	@echo "\033[34mTargets\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@perl -nle'print $& if m{^[a-zA-Z_-\d]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

# Build targets
# -------------

.PHONY: prepare
prepare: dependencies
	bash ./scripts/setup_db.sh

.PHONY: cleanup
cleanup: ## Cleans the whole project, as if it was just cloned
	echo "" | bash ./scripts/nuke_db.sh
	rm -rf _build deps tmp mix.lock .elixir_ls

.PHONY: build
build: ## Build the Docker image for the OTP release
	docker build \
		--build-arg APP_VERSION=$(APP_VERSION)\
		--rm --tag $(DOCKER_LOCAL_IMAGE) .

.PHONY: build-dev
build-dev: ## Build the Docker image for dev purposes
	docker build \
		-f dockerfile.dev \
		--rm --tag $(DOCKER_LOCAL_IMAGE)-dev .

# Development targets
# -------------------

.PHONY: run
run: prepare ## Run the server inside an IEx shell
	iex -S mix phx.server

.PHONY: shell
shell: prepare ## Runs an Interactive REPL with naboo modules loaded
	iex -S mix

.PHONY: dependencies
dependencies: ## Install dependencies
	mix deps.get

.PHONY: test
test: ## Run the test suite
	mix test

# Check, lint and format targets
# ------------------------------

.PHONY: check
check: lint check-format check-unused-dependencies check-dependencies-security check-code-security check-code-coverage ## Run various checks on project files

.PHONY: check-code-coverage
check-code-coverage:
	mix coveralls

.PHONY: check-dependencies-security
check-dependencies-security:
	mix deps.audit

.PHONY: check-code-security
check-code-security:
	mix sobelow --skip --config

.PHONY: check-format
check-format:
	mix format --check-formatted

.PHONY: check-unused-dependencies
check-unused-dependencies:
	mix deps.unlock --check-unused

.PHONY: format
format: ## Format project files
	mix format

.PHONY: lint
lint: lint-elixir

.PHONY: lint-elixir
lint-elixir:
	mix compile --warnings-as-errors --force
	mix credo || true
