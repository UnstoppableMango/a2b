# Plan: nix2container OCI Image with Per-Stack Layers

## Problem

Build an OCI image using nix2container that includes Nix itself plus all builder tool
dependencies, with each builder "stack" in its own layer for composability.

## Context

- `nix2container` is already in `flake.lock` as a transitive dep via `mangonix`, but is
  **not** a direct input in `flake.nix` — must add it.
- The image's purpose: run `nix build` inside the container; tool binaries are pre-populated
  into `/nix/store` via nix2container layers so Nix doesn't need to fetch them.
- `openapi-typescript` (npm pkg) is a private let-binding in `nix/lib/typescript/default.nix`
  — needs to be surfaced for re-use in the image. Cleanest fix: export it from the lib.

## Stacks → Layers

| Layer | Packages |
|---|---|
| `nix` (base) | `pkgs.nix`, `pkgs.bash`, `pkgs.coreutils` |
| `buf` | `pkgs.buf` |
| `kube-vip` | `pkgs.kube-vip` |
| `flux` | `pkgs.fluxcd` |
| `typescript` | `openapi-typescript` npm drv (from `nix/lib/typescript`) |
| `terraform` | `terraform-plugin-codegen-openapi`, `terraform-plugin-codegen-framework` |
| `upjet` | `pkgs.git`, `pkgs.gnumake`, `pkgs.gotools`, `pkgs.terraform`, `pkgs.coreutils`, `pkgs.curlMinimal`, `pkgs.inetutils`, `pkgs.bash` |

## Implementation Steps

1. **Add `nix2container` as a direct flake input** in `flake.nix`, following
   `mangonix.nixpkgs` (the locked rev already exists in `flake.lock`).

2. **Expose `openapi-typescript` package from `nix/lib/typescript/default.nix`** — add it
   as an exported attribute (e.g. `openapi-typescript-pkg`) alongside the builder function,
   so the image definition can reference it without duplicating the `buildNpmPackage` call.

3. **Create `nix/image.nix`** — defines `buildLayer` calls per stack plus the final
   `buildImage`. Accepts `nix2container`, `pkgs`, `lib` (a2b lib), and mangonix tool
   packages as arguments. Exports both individual layers and the composed image.

4. **Wire up in `flake.nix`** — expose the image and individual stack layers as
   `packages.${system}.*`:
   - `packages.image` — full composed image
   - `packages.image-layer-nix`, `packages.image-layer-buf`, … — individual layers

## Notes

- nix2container's `buildLayer { deps = [...]; }` puts store paths into a layer, making
  them available at `/nix/store/...` without downloading during `nix build`.
- The `upjet/gen-provider` builder uses `buildGoApplication` (a Nix build function, not a
  binary) — the store tools it needs at build time (`git`, `gnumake`, etc.) go in the
  upjet layer.
- Individual layer packages allow downstream images to cherry-pick only needed stacks via
  `nix2container.buildImage { layers = [ a2b.packages.image-layer-nix a2b.packages.image-layer-buf ]; }`.
