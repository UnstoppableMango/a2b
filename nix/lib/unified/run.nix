# Runs a unified CLI over `src` and captures the transformed tree as $out.
#
#   a2b.unified.run {
#     name = "docs";
#     src = ./docs;
#     plugins = with unifiedPackages; [ remark-gfm ];
#     settings.bullet = "-";
#   }
#
# Files are rewritten in place (`--output` with no path), so the directory
# layout survives; `--output <dir>` would flatten it.
{
  lib,
  stdenvNoCC,
  remark-cli,
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
      plugins ? [ ],
      settings ? { },
      # File extensions to process, e.g. [ "md" "mdx" ]. The CLI's own default
      # applies when empty.
      extensions ? [ ],
      # Extra engine flags, e.g. [ "--frail" ].
      unifiedFlags ? [ ],
      nativeBuildInputs ? [ ],
      passthru ? { },
      ...
    }:
    let
      rcFile = rc {
        name = finalAttrs.name or "unified";
        inherit plugins settings;
      };
    in
    {
      __structuredAttrs = true;
      strictDeps = true;

      nativeBuildInputs = [ cli ] ++ nativeBuildInputs;

      unifiedProgram = cli.meta.mainProgram;
      unifiedRcPath = rcFile;
      unifiedFlags =
        lib.optionals (extensions != [ ]) [
          "--ext"
          (lib.concatStringsSep "," extensions)
        ]
        ++ unifiedFlags;

      buildPhase = ''
        runHook preBuild

        # --no-config: plugins come from the rc above, never from a
        # .remarkrc in src, which could only name packages by name.
        "$unifiedProgram" --rc-path "$unifiedRcPath" --no-config --no-color \
          "''${unifiedFlags[@]}" . --output

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        cp -r . "$out"

        runHook postInstall
      '';

      passthru = {
        rc = rcFile;
      }
      // passthru;
    };
}
