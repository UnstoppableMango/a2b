{
  description = "ux plugins";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ux = {
      url = "github:unstoppablemango/ux";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        gomod2nix.follows = "gomod2nix";
      };
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [ inputs.treefmt-nix.flakeModule ];
      perSystem =
        { pkgs, system, ... }:
        let
          a2b = pkgs.callPackage ./. {
            inherit (inputs.gomod2nix.legacyPackages.${system}) buildGoApplication;
          };
        in
        {
          apps.ux = inputs.ux.apps.${system}.ux;
          apps.openapi2ts = {
            type = "app";
            program = a2b + "/bin/openapi2ts";
            meta = {
              description = "Convert OpenAPI specs to TypeScript types";
              homepage = "https://github.com/UnstoppableMango/a2b";
              license = [ pkgs.lib.licenses.mit ];
              maintainers = [
                {
                  name = "Erik Rasmussen";
                  email = "erik.rasmussen@unmango.dev";
                }
              ];
            };
          };

          packages.a2b = a2b;
          packages.default = a2b;

          devShells.default = pkgs.callPackage ./shell.nix {
            inherit (inputs.gomod2nix.legacyPackages.${system}) mkGoEnv gomod2nix;
            inherit (inputs.ux.packages.${system}) ux;
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
