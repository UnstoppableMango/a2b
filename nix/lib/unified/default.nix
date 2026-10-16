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
    unifiedCli = unifiedPackages.remark-cli;
  };

  # run with rehype-cli, for HTML.
  rehype = callPackage ./run.nix {
    inherit rc;
    unifiedCli = unifiedPackages.rehype-cli;
  };

  lint = callPackage ./lint.nix {
    inherit rc;
    inherit (unifiedPackages) remark-cli remark-preset-lint-recommended;
  };
}
