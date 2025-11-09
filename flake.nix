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
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      gomod2nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixfmt-tree;

        packages.default = pkgs.buildGoModule (finalAttrs: {
          pname = "a2b";
          version = "0.0.1";
          src = pkgs.lib.cleanSource ./.;
          vendorHash = null;
          proxyVendor = true;

          meta = with pkgs.lib; {
            description = "A collection of ux plugins";
            license = licenses.mit;
            maintainers = with maintainers; [ UnstoppableMango ];
            platforms = platforms.all;
          };
        });

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            gh
            gnumake
            dprint
            go
            nodejs
          ];
        };
      }
    );
}
