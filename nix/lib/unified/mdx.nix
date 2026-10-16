# Compiles every MDX file in `src` to JavaScript with @mdx-js/mdx. $out keeps
# src's layout, holding only the compiled `.js` files.
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
    "extensions"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      cli ? mdx-cli,
      remarkPlugins ? [ ],
      rehypePlugins ? [ ],
      recmaPlugins ? [ ],
      options ? { },
      # `md` files compile as plain markdown, `mdx` ones as MDX.
      extensions ? [ "mdx" ],
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
      mdxExtensions = extensions;

      buildPhase = ''
        runHook preBuild

        files=()
        for ext in "''${mdxExtensions[@]}"; do
          while IFS= read -r -d "" file; do
            files+=("$file")
          done < <(find . -type f -name "*.$ext" -print0 | sort -z)
        done

        if [ ''${#files[@]} -eq 0 ]; then
          echo "no files with extensions ''${mdxExtensions[*]} in src" >&2
          exit 1
        fi

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
