NIX ?= nix

build:
	$(NIX) build

format fmt:
	$(NIX) fmt
