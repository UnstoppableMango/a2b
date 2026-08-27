{
  buf,
  cli,
  lib,
  runCommand,
}:
{
  env ? { },
  excludePaths ? [ ],
  flags ? [ ],
  includeImports ? null,
  includeWkt ? null,
  name,
  paths ? [ ],
  src,
  template ? null,
}:
# `paths` and `excludePaths` resolve relative to the working directory, so
# prefix them with `src`. Buf rejects a path that is itself a module root.
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  ${buf}/bin/buf generate ${lib.escapeShellArg "${src}"} \
    --output "$out" \
    ${cli.optionalArg "template" template} \
    ${cli.repeatArg "path" paths} \
    ${cli.repeatArg "exclude-path" excludePaths} \
    ${cli.boolArg "include-imports" includeImports} \
    ${cli.boolArg "include-wkt" includeWkt} \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
