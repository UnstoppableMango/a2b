{ pkgs, openapi2go }:
let
  cli = pkgs.callPackage ../cli.nix { };
  callPackage = pkgs.lib.callPackageWith (pkgs // { inherit cli openapi2go; });
in
{
  generate = callPackage ./generate.nix { };
}
