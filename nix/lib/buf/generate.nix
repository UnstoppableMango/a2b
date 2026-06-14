{
  buf,
  env ? { },
  flags ? [ ],
  lib,
  name,
  runCommand,
  src,
  template ? null,
}:
let
  templateArgs = lib.optionals (template != null) [ "--template" template ];
in
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  ${buf}/bin/buf generate "${src}" \
    --output "$out" \
    ${lib.escapeShellArgs (templateArgs ++ flags)}

  runHook postRun
''
