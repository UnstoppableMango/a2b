{
  description = "ux plugins";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    ux = {
      url = "github:unstoppablemango/ux";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        gomod2nix.follows = "gomod2nix";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      gomod2nix,
      ux,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        a2b = pkgs.callPackage ./. {
          inherit (gomod2nix.legacyPackages.${system}) buildGoApplication;
        };
      in
      {
        formatter = treefmt-nix.lib.mkWrapper pkgs {
          projectRootFile = "flake.nix";
          programs = {
            gofmt.enable = true;
            nixfmt.enable = true;
            dprint.enable = true;
          };
        };

        apps.ux = ux.apps.${system}.ux;
        apps.openapi2ts = {
          type = "app";
          program = a2b + "/bin/openapi2ts";
        };

        packages.a2b = a2b;
        packages.default = a2b;

        devShells.default = pkgs.callPackage ./shell.nix {
          inherit (gomod2nix.legacyPackages.${system}) mkGoEnv gomod2nix;
          inherit (ux.packages.${system}) ux;
        };
      }
    );
}
