{
  description = "ux plugins";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixfmt-tree;

        packages.default = pkgs.buildGoModule (finalAttrs: {
          pname = "ux-plugins";
          version = "0.1.0";

          src = ./.;
          vendorHash = null;
        });

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gnumake
            go
          ];
        };
      }
    );
}
