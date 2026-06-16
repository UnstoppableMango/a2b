NIX ?= nix
NPM ?= npm

format fmt:
	$(NIX) fmt

update:
	$(NIX) flake update

check:
	$(NIX) flake check

result:
	$(NIX) build

nix/lib/typescript/npm/package-lock.json: nix/lib/typescript/npm/package.json
	$(NPM) install --prefix nix/lib/typescript/npm --package-lock-only

.vscode/settings.json: hack/vscode.json
	cp $< $@

.PHONY: result
