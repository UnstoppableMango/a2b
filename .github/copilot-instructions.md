# Copilot Instructions

## Architecture

`a2b` is a collection of Nix builders for file format conversion, code generation, and manifest building. The entrypoint is the **Nix builders in `nix/lib/`**, exposed as `legacyPackages.lib` in the flake.

- `nix/lib/` — Reusable Nix builder functions (terraform codegen, buf, kube-vip, typescript, upjet)

## Build and Lint

```sh
# Format (Nix)
make fmt                # runs nix fmt (nixfmt)

# Format (JSON, YAML, TS, Markdown, TOML)
dprint fmt

# Nix checks
nix flake check --all-systems
```

## Key Conventions

### Nix lib builders

Functions in `nix/lib/` are exposed as:

```nix
funcName = attrs: import ./file.nix ({ inherit (pkgs) ...; } // attrs);
```

Callers pass required args via `attrs`. Do not use `callPackage` directly for these — the pattern allows callers to supply mandatory arguments.

### Formatting

- Nix: `nix fmt` (via treefmt — nixfmt)
- Everything else: `dprint fmt`
- CI enforces dprint formatting via the `dprint` job
