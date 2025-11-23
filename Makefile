IMAGE ?= ghcr.io/unstoppablemango/a2b:dev

DOCKER ?= docker
GO     ?= go
GINKGO ?= $(GO) tool ginkgo
NIX    ?= nix

build: bin/openapi2ts
deps: gomod2nix.toml

test:
	$(GINKGO) -r .

docker:
	$(DOCKER) build -t ${IMAGE} .

format fmt:
	$(NIX) fmt

tidy:
	$(GO) mod tidy

bin/openapi2ts:
	$(GO) build -o $@ ./cmd/${@F}

result:
	$(NIX) build

gomod2nix.toml: go.mod
	$(GO) tool gomod2nix

.make/nix-build:
	$(NIX) build

.vscode/settings.json: hack/vscode.json
	cp $< $@

.PHONY: bin/openapi2ts result
