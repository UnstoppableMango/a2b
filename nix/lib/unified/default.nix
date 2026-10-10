# Builders that run a unified CLI and capture its output. The CLIs and plugins
# themselves come from unmango/pkgs' unifiedPackages.
{
  lib,
  callPackage,
  unifiedPackages,
}:
let
  rc = callPackage ./rc.nix { };

  run = callPackage ./run.nix {
    inherit rc;
    inherit (unifiedPackages) remark-cli;
  };
in
{
  inherit rc run;

  # run with rehype-cli, for HTML. Takes what run takes, attrs or a
  # finalAttrs function.
  rehype =
    args:
    run (
      finalAttrs:
      { cli = unifiedPackages.rehype-cli; } // (if lib.isFunction args then args finalAttrs else args)
    );

  lint = callPackage ./lint.nix {
    inherit rc;
    inherit (unifiedPackages) remark-cli remark-preset-lint-recommended;
  };
}
