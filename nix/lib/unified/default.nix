# Builders that run a unified CLI and capture its output. The CLIs and plugins
# themselves come from unmango/pkgs' unifiedPackages.
{ callPackage, unifiedPackages }:
let
  toPlugin = callPackage ./plugin.nix { };
  rc = callPackage ./rc.nix { inherit toPlugin; };
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

  # run with retext-cli, for prose.
  retext = callPackage ./run.nix {
    inherit rc;
    unifiedCli = unifiedPackages.retext-cli;
  };

  lint = callPackage ./lint.nix {
    inherit rc;
    unifiedCli = unifiedPackages.remark-cli;
    defaultPlugins = [ unifiedPackages.remark-preset-lint-recommended ];
  };

  # lint with retext-cli, for prose.
  retextLint = callPackage ./lint.nix {
    inherit rc;
    unifiedCli = unifiedPackages.retext-cli;
    defaultPlugins = with unifiedPackages; [
      retext-english
      retext-repeated-words
    ];
  };

  mdx = callPackage ./mdx.nix {
    inherit toPlugin;
    inherit (unifiedPackages) mdx-cli;
  };
}
