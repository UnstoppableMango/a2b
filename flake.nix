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
        lib = nixpkgs.lib;
      in
      {
        formatter = pkgs.nixfmt-tree;

        packages.default = pkgs.buildGoModule (finalAttrs: {
          pname = "a2b";
          version = "0.0.1";
          src = lib.cleanSource ./.;
          vendorHash = null;
          proxyVendor = true;

          meta = with lib; {
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
