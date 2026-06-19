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
  templateArg = lib.optionalString (
    template != null
  ) "--template ${lib.escapeShellArg (toString template)}";
in
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  ${buf}/bin/buf generate "${src}" \
    --output "$out" \
    ${templateArg} \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
