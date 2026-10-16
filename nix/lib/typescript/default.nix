{ pkgs }:
let
  openapi-typescript = pkgs.buildNpmPackage {
    pname = "openapi-typescript";
    version = "7.13.0";
    src = ./npm;
    npmDepsHash = "sha256-8OarmQHtnxzyoP9q5DYvt/luP4Z6EFj+EDMLiC9Jt8A=";
    dontNpmBuild = true;
  };

  callPackage = pkgs.lib.callPackageWith (packages // pkgs // { inherit openapi-typescript; });

  packages = {
    openapi-typescript = callPackage ./openapi-typescript.nix { };
  };
in
packages
