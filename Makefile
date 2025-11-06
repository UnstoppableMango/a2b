GO     ?= go
GINKGO ?= $(GO) tool ginkgo
NIX    ?= nix

build:
	$(NIX) build

test:
	$(GINKGO) -r .

format fmt:
	$(NIX) fmt

tidy:
	$(GO) mod tidy
