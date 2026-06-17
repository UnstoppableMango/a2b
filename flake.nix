{
  description = "ux plugins";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";

    mangonix = {
      url = "github:UnstoppableMango/nix";
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
          inputs',
          pkgs,
          ...
        }:
        {
          legacyPackages.lib = pkgs.callPackage ./nix/lib {
            inherit (inputs'.mangonix.packages)
              terraform-plugin-codegen-framework
              terraform-plugin-codegen-openapi
              ;
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              git
              gh
              gnumake
              docker
              dprint
              fluxcd
              nixd
              nixfmt
              nodejs
            ];
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              # dprint.enable = true;
            };
          };
        };
    };
}
