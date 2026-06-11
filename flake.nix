{
  description = "ux plugins";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";

    docker2nix = {
      url = "github:UnstoppableMango/docker2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.gomod2nix.follows = "gomod2nix";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.inputs.systems.follows = "systems";
    };

    ux = {
      url = "github:unstoppablemango/ux";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.gomod2nix.follows = "gomod2nix";
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
          lib,
          system,
          ...
        }:
        let
          inherit (inputs'.gomod2nix.legacyPackages) gomod2nix buildGoApplication;
          inherit (inputs'.ux.packages) ux;

          petstore = pkgs.callPackage ./nix/petstore.nix { };
          a2b = pkgs.callPackage ./nix { inherit buildGoApplication petstore ux; };

          me = {
            name = "Erik Rasmussen";
            email = "erik.rasmussen@unmango.dev";
          };
        in
        {
          apps.ux = {
            type = "app";
            program = "${ux}/bin/ux";
            meta.description = "UX CLI";
          };

          apps.openapi2ts = {
            type = "app";
            program = "${a2b}/bin/openapi2ts";
            meta = with lib; {
              description = "Convert OpenAPI specs to TypeScript types";
              homepage = "https://github.com/UnstoppableMango/a2b";
              license = [ licenses.mit ];
              maintainers = [ me ];
              mainProgram = "openapi2ts";
            };
          };

          packages = {
            inherit a2b petstore;
            default = a2b;
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              git
              gh
              gnumake
              docker
              dprint
              go
              nixd
              nixfmt
              nodejs
              ginkgo
              gomod2nix
              ux
            ];

            DOCKER = lib.getExe pkgs.docker;
            GO = lib.getExe pkgs.go;
            GINKGO = lib.getExe pkgs.ginkgo;
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              gofmt.enable = true;
              nixfmt.enable = true;
              # dprint.enable = true;
            };
          };
        };
    };
}
