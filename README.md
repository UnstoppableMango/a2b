# a2b

[![CI](https://github.com/UnstoppableMango/a2b/actions/workflows/ci.yml/badge.svg)](https://github.com/UnstoppableMango/a2b/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Built with Nix](https://img.shields.io/badge/Built%20with-Nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![Last commit](https://img.shields.io/github/last-commit/UnstoppableMango/a2b)](https://github.com/UnstoppableMango/a2b/commits/main)

A grab-bag of [Nix](https://nixos.org) builders that generate config, code, and manifests for common developer tools, protobufs with Buf, Kubernetes manifests with Flux, Terraform providers, tree-sitter grammars, TypeScript types from OpenAPI, and more.

You don't need to know Nix conventions to use this.
Everything below shows what to run and what you get.

## Why

Generating protobuf code, Kubernetes manifests, provider bindings, and the like usually means installing and version-pinning a pile of separate CLIs (Buf, tree-sitter, Terraform codegen, ...) and wiring them into scripts by hand.
These builders wrap that tooling as Nix derivations instead, so the generated output is reproducible, the tool versions are pinned by the flake lock, and you get it as a normal build input in your own flake rather than a shell script to maintain.

## What's in here

| Tool | What it does |
| --- | --- |
| `buf` | Build, convert, and generate code from protobuf schemas using [Buf](https://buf.build) |
| `flux` | Generate [Flux CD](https://fluxcd.io) Kustomizations, GitRepository sources, and install manifests |
| `gossamer` | Build and check Gossamer projects |
| `kube-vip` | Generate a [kube-vip](https://kube-vip.io) manifest Pod |
| `terraform` | Generate Terraform provider code and specs using `terraform-plugin-codegen` |
| `tree-sitter` | Build, generate, parse, and query [tree-sitter](https://tree-sitter.github.io) grammars |
| `typescript` | Generate TypeScript types from an OpenAPI spec |
| `upjet` | Generate [Upjet](https://github.com/crossplane/upjet)-based Crossplane providers |

## Requirements

- [Nix](https://nixos.org/download) with flakes enabled

That's the only thing you need installed on your machine.
Each builder pulls in whatever tool it wraps (Buf, tree-sitter, etc.) automatically through Nix, you don't install those yourself.

## Using a builder

Every builder is a function exposed under `legacyPackages.lib` in this flake.
You call it from your own flake.

Add `a2b` as an input:

```nix
inputs.a2b.url = "github:UnstoppableMango/a2b";
```

Then reach into `legacyPackages.<system>.lib` for the builder you need:

```nix
{ a2b, pkgs, ... }:
let
  lib = a2b.legacyPackages.${pkgs.system}.lib;
in
{
  # Example: generate TypeScript types from an OpenAPI spec
  packages.api-types = lib.typescript.openapi-typescript {
    src = ./openapi.yaml;
  };
}
```

Each builder folder under [`nix/lib/`](nix/lib) has its own arguments, check the `default.nix` in that folder (e.g. [`nix/lib/typescript/default.nix`](nix/lib/typescript/default.nix)) to see what it expects.

## Development

Clone the repo and enter the dev shell, which comes with `git`, `gh`, `make`, `docker`, `fluxcd`, `nixd`, `nixfmt`, `nodejs`, and `tree-sitter` preinstalled:

```bash
git clone git@github.com:UnstoppableMango/a2b
cd a2b
nix develop
```

Common tasks:

```bash
make fmt      # format the repo (nixfmt, prettier)
make check    # validate the flake (nix flake check)
```

If you change `nix/lib/typescript/npm/package.json`, regenerate its lockfile with:

```bash
make nix/lib/typescript/npm/package-lock.json
```

## License

[MIT](LICENSE)
