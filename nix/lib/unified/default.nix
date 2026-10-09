# Builders that run a unified CLI and capture its output. The CLIs and plugins
# themselves come from unmango/pkgs' unifiedPackages.
{ callPackage, unifiedPackages }:
let
  rc = callPackage ./rc.nix { };
in
{
  inherit rc;

  run = callPackage ./run.nix {
    inherit rc;
    inherit (unifiedPackages) remark-cli;
  };
}
