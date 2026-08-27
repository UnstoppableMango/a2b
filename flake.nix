{
  description = "ux plugins";

  # legacyPackages.lib.upjet transitively depends on mangopkgs'
  # gomod2nix-based buildGoApplication, which requires IFD to evaluate.
  # Building that output needs allow-import-from-derivation=true regardless.
  nixConfig = {
    allow-import-from-derivation = false;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/triplet";
    flake-parts.url = "github:hercules-ci/flake-parts";

    mangopkgs = {
      url = "github:unmango/pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    pulumi2nix = {
      url = "github:UnstoppableMango/pulumi2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    # pulumipkgs consumes pulumi2nix. Pointing it at the input above keeps
    # lib.pulumi and the builders behind lib.pulumiPackages on one revision.
    pulumipkgs = {
      url = "github:unmango/pulumipkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.pulumi2nix.follows = "pulumi2nix";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        inputs.treefmt-nix.flakeModule
        ./nix/lib/flake-module.nix
      ];

      # Re-exported from the sibling flakes so a consumer that already depends
      # on a2b reaches pulumi2nix's option tree and pulumipkgs' package set
      # without adding either as an input of its own.
      flake = {
        overlays.pulumiPackages = inputs.pulumipkgs.overlays.default;
        flakeModules.pulumi = inputs.pulumi2nix.flakeModules.default;
      };

      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              git
              gh
              gnumake
              docker
              fluxcd
              nixd
              nixfmt
              nodejs
              pulumi
              tree-sitter
            ];
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              prettier = {
                enable = true;
                excludes = [
                  "**/package-lock.json"
                  ".claude/**"
                ];
              };
            };
          };
        };
    };
}
