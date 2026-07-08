{
  lib,
  openapi-typescript,
  runCommand,
}:
{
  env ? { },
  flags ? [ ],
  name,
  src,
}:
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  ${openapi-typescript}/bin/openapi-typescript ${lib.escapeShellArg (toString src)} \
    --output $out \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
