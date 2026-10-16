# Compiles every file in `src` to JavaScript with @mdx-js/mdx, which reads
# `.md` as markdown and anything else as MDX. $out keeps src's layout,
# holding only the compiled `.js` files. Narrow `src` with lib.fileset to
# leave files out.
#
#   a2b.unified.mdx {
#     name = "docs";
#     src = ./docs;
#     remarkPlugins = with unifiedPackages; [ remark-gfm ];
#     options.jsx = true;
#   }
#
# `options` are @mdx-js/mdx's compile options; the three plugin lists take
# plugins the way `run` does.
{
  lib,
  stdenvNoCC,
  formats,
  mdx-cli,
  toPlugin,
}:
lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;

  excludeDrvArgNames = [
    "cli"
    "remarkPlugins"
    "rehypePlugins"
    "recmaPlugins"
    "options"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      cli ? mdx-cli,
      remarkPlugins ? [ ],
      rehypePlugins ? [ ],
      recmaPlugins ? [ ],
      options ? { },
      nativeBuildInputs ? [ ],
      passthru ? { },
      ...
    }:
    let
      optionsFile = (formats.json { }).generate "${finalAttrs.name or "mdx"}-options.json" (
        options
        // lib.filterAttrs (_: plugins: plugins != [ ]) {
          remarkPlugins = map toPlugin remarkPlugins;
          rehypePlugins = map toPlugin rehypePlugins;
          recmaPlugins = map toPlugin recmaPlugins;
        }
      );
    in
    {
      __structuredAttrs = true;
      strictDeps = true;

      nativeBuildInputs = [ cli ] ++ nativeBuildInputs;

      mdxProgram = lib.getExe cli;
      mdxOptionsPath = optionsFile;

      buildPhase = ''
        runHook preBuild

        files=()
        while IFS= read -r -d "" file; do
          files+=("$file")
        done < <(find . -type f -print0 | sort -z)

        "$mdxProgram" --options "$mdxOptionsPath" --out-dir "$NIX_BUILD_TOP/compiled" "''${files[@]}"

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        cp -r "$NIX_BUILD_TOP/compiled" "$out"

        runHook postInstall
      '';

      passthru = {
        options = optionsFile;
      }
      // passthru;
    };
}
