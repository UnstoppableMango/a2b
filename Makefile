NIX ?= nix

format fmt:
	$(NIX) fmt

update:
	$(NIX) flake update

check:
	$(NIX) flake check

.vscode/settings.json: hack/vscode.json
	cp $< $@
