# Static website with every view of a LikeC4 workspace, ready for any static host.
# `likec4 build` logs model errors but still exits 0, so pair it with
# `validate` in `checks` to fail on a broken model.
{
  cli,
  graphviz,
  lib,
  likec4,
  runCommand,
}:
{
  base ? null,
  buildWebcomponent ? true,
  env ? { },
  flags ? [ ],
  name,
  outputSingleFile ? false,
  public ? null,
  src,
  theme ? null,
  title ? null,
  # Lays views out with the Graphviz binaries instead of the bundled WASM build.
  useDot ? false,
  useHashHistory ? false,
  webcomponentPrefix ? null,
}:
let
  attrs = env // {
    nativeBuildInputs = env.nativeBuildInputs or [ ] ++ lib.optional useDot graphviz;
  };
in
runCommand name attrs ''
  runHook preBuild

  export HOME="$(mktemp -d)"
  ${likec4}/bin/likec4 build \
    ${cli.optionalArg "base" base} \
    ${lib.optionalString useDot "--use-dot"} \
    ${lib.optionalString useHashHistory "--use-hash-history"} \
    ${lib.optionalString outputSingleFile "--output-single-file"} \
    ${cli.optionalArg "public" public} \
    ${cli.optionalArg "theme" theme} \
    ${cli.optionalArg "title" title} \
    ${cli.optionalArg "webcomponent-prefix" webcomponentPrefix} \
    ${lib.optionalString (!buildWebcomponent) "--no-build-webcomponent"} \
    --output $out \
    ${lib.escapeShellArgs flags} \
    ${lib.escapeShellArg "${src}"}

  runHook postBuild
''
