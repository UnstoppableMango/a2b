{
  buf,
  lib,
  runCommand,
}:
{
  env ? { },
  flags ? [ ],
  input,
  name,
}:
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  ${buf}/bin/buf build ${input} \
    --output $out \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
