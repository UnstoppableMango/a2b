# Lints `src` with a unified CLI and fails the build on any warning
# (`--frail`). $out is the lint report, empty when there is nothing to say.
#
#   a2b.unified.lint {
#     name = "docs-lint";
#     src = ./docs;
#     plugins = with unifiedPackages; [ remark-gfm remark-preset-lint-recommended ];
#   }
#
# Files are only read, never rewritten.
{
  lib,
  stdenvNoCC,
  remark-cli,
  remark-preset-lint-recommended,
  rc,
}:
lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;

  excludeDrvArgNames = [
    "cli"
    "plugins"
    "settings"
    "extensions"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      cli ? remark-cli,
      plugins ? [ remark-preset-lint-recommended ],
      settings ? { },
      extensions ? [ ],
      # Extra engine flags, e.g. [ "--ignore-pattern" "vendor/**" ].
      unifiedFlags ? [ ],
      passthru ? { },
      ...
    }:
    let
      rcFile = rc {
        name = finalAttrs.name or "unified-lint";
        inherit plugins settings;
      };
    in
    {
      __structuredAttrs = true;
      strictDeps = true;

      unifiedProgram = lib.getExe cli;
      unifiedRcPath = rcFile;
      unifiedFlags =
        lib.optionals (extensions != [ ]) [
          "--ext"
          (lib.concatStringsSep "," extensions)
        ]
        ++ unifiedFlags;

      dontInstall = true;

      buildPhase = ''
        runHook preBuild

        # --quiet keeps files without messages out of the report, and
        # --no-stdout keeps the processed documents out of it.
        if ! "$unifiedProgram" --rc-path "$unifiedRcPath" --no-config --no-color \
          --frail --quiet --no-stdout "''${unifiedFlags[@]}" . 2> report; then
          cat report >&2
          exit 1
        fi
        cp report "$out"

        runHook postBuild
      '';

      passthru = {
        rc = rcFile;
      }
      // passthru;
    };
}
