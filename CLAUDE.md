# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Format
make fmt                            # nix fmt (nixfmt)

# Nix
nix build                           # builds default (currently undefined — lib only)
nix flake check                     # validate flake
make check                          # alias for nix flake check

# Update npm lockfile after package.json changes
make nix/lib/typescript/npm/package-lock.json
```

## Architecture

**`a2b` is a collection of Nix builders** for file format conversion, code generation, and manifest building. The `nix/lib/` builders are the entrypoint — exposed as `legacyPackages.lib` in the flake.

### Nix layer (`nix/`)

- `nix/lib/` — Nix library functions exposed as `legacyPackages.lib` in the flake. These are **reusable derivation builders** for other projects:
  - `buf` — `build`, `convert`, `generate` derivations for Buf (protobuf toolchain)
  - `kube-vip` — `manifestPod` for kube-vip manifest generation
  - `pulumi` — `convert`, `genSdk` for Pulumi CLI codegen (schema-based SDK generation, IaC conversion)
  - `terraform` — `genProviderSpec`, `genProvider`, `scaffold` using `terraform-plugin-codegen-*` tools
  - `typescript` — `openapi-typescript` for generating TypeScript types from OpenAPI specs
  - `upjet` — `genProviderTemplate`, `genProvider` for Upjet-based Crossplane providers
  - `strings` — utility: `toSnakeCase`
