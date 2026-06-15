# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Build
make build                          # builds bin/openapi2ts
go build -o bin/openapi2ts ./cmd/openapi2ts

# Test (requires petstore.json)
make test                           # fetches petstore via nix, runs ginkgo
PETSTORE_PATH=bin/petstore.json go tool ginkgo -r .

# Single test suite
go tool ginkgo ./cmd/openapi2ts/

# Format
make fmt                            # nix fmt (gofmt + nixfmt)

# Nix
nix build                           # builds default package (a2b)
nix flake check                     # validate flake
make check                          # alias for nix flake check

# Dependency sync (run after go.mod changes)
go mod tidy
go tool gomod2nix --outdir ./nix    # regenerates nix/gomod2nix.toml
```

## Architecture

**`a2b` is a collection of [ux](https://github.com/unstoppablemango/ux) plugins and Nix builders** for file format conversion, code generation, and manifest building. The `nix/lib/` builders are the current preferred entrypoint. The Go/ux plugin layer is experimental.

### Go layer (`pkg/`, `cmd/`)

- `pkg/` declares plugins using `github.com/unstoppablemango/ux/pkg/plugin`. Each plugin is a `plugin.Cli` struct specifying the external binary and args, with `ux.InputFile()` / `ux.OutputPath()` reading env vars (`UX_INPUT_FILE`, `UX_OUTPUT_PATH`) at runtime.
- `cmd/<name>/main.go` calls `cli.PluginMain(pkg.SomePlugin)` — that's the entire binary entrypoint pattern.
- Tests use Ginkgo/Gomega. `BeforeSuite` compiles the binary via `gexec.Build` and requires `PETSTORE_PATH` env var pointing to a petstore OpenAPI spec JSON.

### Nix layer (`nix/`)

- `nix/default.nix` — packages the Go application via `gomod2nix`'s `buildGoApplication`.
- `nix/gomod2nix.toml` — generated lockfile for Nix Go builds; must stay in sync with `go.mod`/`go.sum`.
- `nix/lib/` — Nix library functions exposed as `legacyPackages.lib` in the flake. These are **reusable derivation builders** for other projects:
  - `buf` — `build`, `convert`, `generate` derivations for Buf (protobuf toolchain)
  - `kube-vip` — `manifestPod` for kube-vip manifest generation
  - `terraform` — `genProviderSpec`, `genProvider`, `scaffold` using `terraform-plugin-codegen-*` tools
  - `upjet` — `genProviderTemplate`, `genProvider` for Upjet-based Crossplane providers
  - `strings` — utility: `toSnakeCase`

### Key dependency: `ux`

`github.com/unstoppablemango/ux` provides the plugin framework. When adding new plugins, follow the pattern in `pkg/openapi-typescript.go`: return a `plugin.Cli` from a function that accepts `plugin.Ux`.

## Testing notes

- Tests compile the binary at test time (`gexec.Build`) — no pre-built binary needed for `go test`.
- `PETSTORE_PATH` must point to the petstore OpenAPI spec. `make test` fetches it via `nix build .#petstore`.
- Nix `doCheck = false` in `nix/default.nix` because `openapi-typescript` npm package isn't pre-installed in the Nix sandbox yet.
