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
# To generate for one module of a `buf.mkWorkspace` result, point `src` at that
# module directory, e.g. `src = "${workspace}/proto"`. Buf walks up to the
# workspace buf.yaml, so imports still resolve against every other module while
# only that module's files are generated.
#
# `paths` and `excludePaths` narrow further, and are resolved relative to the
# working directory, so prefix them with `src` for a store path. Buf rejects a
# path that is itself a module root; use it as the input instead.
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
