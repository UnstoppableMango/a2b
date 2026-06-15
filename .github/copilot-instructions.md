# Copilot Instructions

## Architecture

`a2b` is a collection of [ux](https://github.com/unstoppablemango/ux) plugins. The **preferred entrypoint is the Nix builders in `nix/lib/`** — the `ux` plugin interface and the binaries in `cmd/` are experimental and secondary.

- `pkg/` — Go library defining plugin implementations (e.g., `OpenApiTypeScript`)
- `cmd/<name>/` — CLI entry points; each calls `cli.PluginMain(<plugin func>)` from `ux`
- `nix/lib/` — Reusable Nix builder functions (terraform codegen, buf, kube-vip, upjet)

A plugin is a struct implementing `decl.Plugin` from `ux`. The `plugin.Cli` type wraps an external CLI invocation. Plugins receive input/output paths from the `ux` runtime via the `plugin.Ux` argument (which reads env vars like `UX_INPUT_FILE` and `UX_OUTPUT_PATH`).

## Build, Test, and Lint

```sh
# Build
make build              # builds bin/openapi2ts

# Test (requires petstore spec)
make bin/petstore.json  # build test fixture via Nix (one-time)
make test               # runs full Ginkgo suite

# Run a single test file / describe block
go tool ginkgo run ./cmd/openapi2ts/
go tool ginkgo run --focus "should work" ./cmd/openapi2ts/

# Format (Go + Nix)
make fmt                # runs nix fmt (gofmt + nixfmt)

# Format (JSON, YAML, TS, Markdown, TOML, Dockerfile)
dprint fmt

# Nix checks
nix flake check --all-systems
```

The `PETSTORE_PATH` env var must be set when running tests — `make test` handles this automatically via the `Makefile`'s `export PETSTORE_PATH := $(abspath bin/petstore.json)`.

## Key Conventions

### Adding a new plugin

1. Add a function in `pkg/` returning `decl.Plugin`, using `plugin.Cli` for CLI wrappers.
2. Create `cmd/<name>/main.go` calling `cli.PluginMain(<your func>)`.
3. Add a build target to `Makefile` and a Nix package in `nix/default.nix` / `flake.nix`.
4. Write a Ginkgo test suite in `cmd/<name>/` (suite file + spec file).

### Nix lib builders

Functions in `nix/lib/` are exposed as:

```nix
funcName = attrs: import ./file.nix ({ inherit (pkgs) ...; } // attrs);
```

Callers pass required args via `attrs`. Do not use `callPackage` directly for these — the pattern allows callers to supply mandatory arguments.

### `gomod2nix.toml`

This file is auto-generated. After any `go.mod` change, regenerate it:

```sh
make deps   # runs go tool gomod2nix --outdir ./nix
```

Do not manually edit `nix/gomod2nix.toml`.

### Formatting

- Go and Nix: `nix fmt` (via treefmt — gofmt + nixfmt)
- Everything else: `dprint fmt`
- CI enforces dprint formatting via the `dprint` job
