{
  buf,
  cli,
  env ? { },
  flags ? [ ],
  lib,
  name,
  runCommand,
  src,
  template ? null,
}:
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  ${buf}/bin/buf generate "${src}" \
    --output "$out" \
    ${cli.optionalArg "template" template} \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
