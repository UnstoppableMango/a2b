{ pkgs, likec4 }:
let
  cli = pkgs.callPackage ../cli.nix { };
  callPackage = pkgs.lib.callPackageWith (pkgs // { inherit cli likec4; });
in
{
  build = callPackage ./build.nix { };
  codegen = callPackage ./codegen.nix { };
  exportJson = callPackage ./export-json.nix { };
  validate = callPackage ./validate.nix { };
}
