{ pkgs }:
let
  openapi-typescript = pkgs.buildNpmPackage {
    pname = "openapi-typescript";
    version = "7.13.0";
    src = ./npm;
    npmDepsHash = "sha256-wvsOoRLsKxLMOgW6rxj4VrfXHbFqoeRFg9l6lPauVI0=";
    dontNpmBuild = true;
  };

  callPackage = pkgs.lib.callPackageWith (packages // pkgs // { inherit openapi-typescript; });

  packages = {
    openapi-typescript = callPackage ./openapi-typescript.nix;
  };
in
packages
