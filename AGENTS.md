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
  - `flux` — `createKustomization`, `createSourceGit`, `gotkComponents`, `install` for Flux CD
  - `gossamer` — `build`, `check`, `runCommand` derivations
  - `kube-vip` — `manifestPod` for kube-vip manifest generation
  - `pulumi` — re-export of [UnstoppableMango/pulumi2nix](https://github.com/UnstoppableMango/pulumi2nix)'s builders (`mkPulumiPackage`, `mkTerraformBridgeProvider`, `mkComponentPackage`, `mkSdkSource`, ...), not defined here
  - `pulumiPackages` — re-export of [unmango/pulumipkgs](https://github.com/unmango/pulumipkgs)' provider plugins, language runtimes, and components, not defined here
  - `terraform` — `genProviderSpec`, `genProvider`, `scaffold` using `terraform-plugin-codegen-*` tools
  - `tree-sitter` — `build`, `generate`, `highlight`, `init`, `parse`, `playground`, `query` derivations
  - `typescript` — `openapi-typescript` for generating TypeScript types from OpenAPI specs
  - `upjet` — `genProviderTemplate`, `genProvider` for Upjet-based Crossplane providers
  - `strings` — utility: `toSnakeCase`
- `flake.overlays.pulumiPackages` and `flake.flakeModules.pulumi` re-export pulumipkgs' overlay and pulumi2nix's flake-parts module, so a consumer reaches both through a2b alone.

### Gotchas

- `nixConfig.allow-import-from-derivation = false` in `flake.nix`. Building `legacyPackages.lib.upjet` needs IFD regardless (transitively depends on mangopkgs' gomod2nix-based `buildGoApplication`), so pass `--option allow-import-from-derivation true` when building that output.
