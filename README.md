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

| Tool             | What it does                                                                                            |
| ---------------- | ------------------------------------------------------------------------------------------------------- |
| `buf`            | Build, convert, generate code from, and vendor external protobuf schemas using [Buf](https://buf.build) |
| `flux`           | Generate [Flux CD](https://fluxcd.io) Kustomizations, GitRepository sources, and install manifests      |
| `gossamer`       | Build and check Gossamer projects                                                                       |
| `kube-vip`       | Generate a [kube-vip](https://kube-vip.io) manifest Pod                                                 |
| `pulumi`         | Build [Pulumi](https://www.pulumi.com) providers, schemas, and language SDKs                            |
| `pulumiPackages` | Prebuilt Pulumi provider plugins, language runtimes, and components                                     |
| `terraform`      | Generate Terraform provider code and specs using `terraform-plugin-codegen`                             |
| `tree-sitter`    | Build, generate, parse, and query [tree-sitter](https://tree-sitter.github.io) grammars                 |
| `typescript`     | Generate TypeScript types from an OpenAPI spec                                                          |
| `upjet`          | Generate [Upjet](https://github.com/crossplane/upjet)-based Crossplane providers                        |

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

`pulumi` and `pulumiPackages` are the two exceptions, with no folder of their own, see below.

## Pulumi

`lib.pulumi` and `lib.pulumiPackages` are re-exports of two sibling flakes, so a2b is the only input you need for either.

`lib.pulumi` holds the builders from [pulumi2nix](https://github.com/UnstoppableMango/pulumi2nix): one per Pulumi artifact (`mkGenTool`, `mkSchema`, `mkProviderPlugin`, `mkSdkSource`, `mkSdk`), plus recipes that compose them (`mkPulumiPackage`, `mkTerraformBridgeProvider`, `mkComponentPackage`, `mkDynamicBridgeProvider`).

```nix
{ a2b, pkgs, ... }:
let
  pulumi = a2b.legacyPackages.${pkgs.system}.lib.pulumi;
in
{
  packages.my-provider = pulumi.mkTerraformBridgeProvider rec {
    owner = "pulumi";
    repo = "pulumi-random";
    version = "4.14.0";
    hash = "sha256-...";
    vendorHash = "sha256-...";
    cmdGen = "pulumi-tfgen-random";
    cmdRes = "pulumi-resource-random";
  };
}
```

Every argument each builder accepts is documented in [pulumi2nix's `docs/usage.md`](https://github.com/UnstoppableMango/pulumi2nix/blob/main/docs/usage.md).

`lib.pulumiPackages` is the package set from [pulumipkgs](https://github.com/unmango/pulumipkgs): providers already packaged at a pinned version, the language runtimes the Pulumi CLI shells out to, and source-based components.

```nix
devShells.default = pkgs.mkShell {
  packages = [
    pkgs.pulumi
    a2b.legacyPackages.${pkgs.system}.lib.pulumiPackages.github
    a2b.legacyPackages.${pkgs.system}.lib.pulumiPackages.pulumi-nodejs
  ];
};
```

Two further outputs re-export the pieces that don't fit under `lib`:

- `a2b.overlays.pulumiPackages` adds `pulumiPackages` to your own nixpkgs, reachable as `pkgs.pulumiPackages.<name>`.
- `a2b.flakeModules.pulumi` is pulumi2nix's flake-parts module, which turns a `pulumi.terraformBridgeProviders.<name>` declaration into `packages.<name>` along with its schema and SDK outputs.

## Vendoring external protos

Protobuf schemas routinely import definitions that live in someone else's repository.
Buf's own answer is a dependency on the [BSR](https://buf.build/product/bsr), resolved over the network while the build runs.
That doesn't work in a Nix build sandbox, and plenty of schemas aren't published there at all.
The Kubernetes API protos are the standard example: they live in the Kubernetes repositories, and `k8s.io/api/core/v1/generated.proto` imports five files from `k8s.io/apimachinery`.

`buf.vendor` copies protos out of a source you pinned yourself into a tree whose layout matches the import paths, and `buf.mkWorkspace` stitches those trees together with your own protos into a [v2 buf workspace](https://buf.build/docs/configuration/v2/buf-yaml/).
Modules in a workspace resolve imports between each other automatically, so there is no `deps` entry, no `buf.lock`, and no network access once the sources are fetched.

```nix
{ a2b, pkgs, ... }:
let
  buf = a2b.legacyPackages.${pkgs.system}.lib.buf;

  # The kubernetes/api repo root is the import prefix `k8s.io/api`.
  k8sApi = buf.vendor {
    name = "k8s-api-protos";
    prefix = "k8s.io/api";
    src = pkgs.fetchFromGitHub {
      owner = "kubernetes";
      repo = "api";
      rev = "v0.34.1";
      hash = "sha256-...";
    };
  };

  k8sApimachinery = buf.vendor {
    name = "k8s-apimachinery-protos";
    prefix = "k8s.io/apimachinery";
    src = pkgs.fetchFromGitHub {
      owner = "kubernetes";
      repo = "apimachinery";
      rev = "v0.34.1";
      hash = "sha256-...";
    };
  };

  workspace = buf.mkWorkspace {
    name = "my-protos";
    modules = [
      {
        path = "third_party/k8s-api";
        src = k8sApi;
        vendor = true;
      }
      {
        path = "third_party/k8s-apimachinery";
        src = k8sApimachinery;
        vendor = true;
      }
      {
        path = "proto";
        src = ./proto;
      }
    ];
  };
in
{
  packages.protos-go = buf.generate {
    name = "my-protos-go";
    # Point at your own module, not the workspace root, so only your protos are
    # generated. Buf still resolves imports against every other module.
    src = "${workspace}/proto";
    template = buf.mkTemplate {
      plugins = [
        {
          package = pkgs.protoc-gen-go;
          out = "gen/go";
          opt = [ "paths=source_relative" ];
        }
      ];
    };
  };
}
```

`vendor = true` on a module keeps third-party protos out of `buf lint` and `buf breaking`.

Where a repository nests its protos under a directory that is already laid out by import path, use `root` to strip that directory instead of `prefix` to add one.
The Kubernetes monorepo is the usual case:

```nix
buf.vendor {
  name = "k8s-protos";
  root = "staging/src";
  src = pkgs.fetchFromGitHub {
    owner = "kubernetes";
    repo = "kubernetes";
    rev = "v1.34.1";
    hash = "sha256-...";
  };
}
```

`includes` and `excludes` narrow which subdirectories of `root` are walked.
Getting `root` wrong fails the build with `buf.vendor: no .proto files found under ...` rather than producing an empty module.

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
