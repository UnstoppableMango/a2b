{
  buf,
  env ? { },
  flags ? [ ],
  input,
  lib,
  name,
  runCommand,
}:
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  ${buf}/bin/buf build ${input} \
    --output $out \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
