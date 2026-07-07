{
  description = "ux plugins";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";

    mangopkgs = {
      url = "github:unmango/pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
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
      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem =
        {
          config,
          inputs',
          pkgs,
          ...
        }:
        {
          legacyPackages.lib = pkgs.callPackage ./nix/lib {
            inherit (inputs'.mangopkgs.packages)
              gossamer
              terraform-plugin-codegen-framework
              terraform-plugin-codegen-openapi
              ;
          };

          # Forces legacyPackages.lib to evaluate, catching import errors and wrong
          # function signatures. Does NOT catch missing attrs from external inputs;
          # those propagate as lazy error thunks until a derivation is actually built.
          checks.lib = pkgs.writeText "lib-check" (
            builtins.toJSON (builtins.attrNames config.legacyPackages.lib)
          );

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
