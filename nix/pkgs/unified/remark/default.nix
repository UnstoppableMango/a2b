# remarkjs/remark: remark, remark-cli, remark-parse and remark-stringify.
{
  lib,
  buildUnifiedWorkspace,
  fetchFromGitHub,
  testers,
  unifiedPackages,
  wrapUnifiedCli,
}:
let
  packages = buildUnifiedWorkspace {
    pname = "remark";

    src = fetchFromGitHub {
      owner = "remarkjs";
      repo = "remark";
      tag = "remark-cli@12.0.1";
      hash = "sha256-kiaMI42smtTNiGxM1quGCpQx/YnRfYpAmDhtuPzV6fA=";
    };

    lockfile = ./package-lock.json;
    workspaces = lib.importJSON ./workspaces.json;
    npmDepsHash = "sha256-f4axPvlv37i9k2Y4GKtLHLIgN3+K2tK7RbK7ohJdKr4=";
    packages = unifiedPackages;

    meta = {
      homepage = "https://remark.js.org";
      license = lib.licenses.mit;
    };
  };
in
packages
// {
  remark-cli = packages.remark-cli.overrideAttrs (
    finalAttrs: prev: {
      passthru = prev.passthru // {
        # remark-cli.withPlugins (ps: [ ps.remark-gfm ])
        withPlugins =
          f:
          wrapUnifiedCli {
            cli = finalAttrs.finalPackage;
            plugins = f unifiedPackages;
          };

        tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
      };

      meta = prev.meta // {
        description = "CLI to process markdown with remark";
        mainProgram = "remark";
      };
    }
  );
}
