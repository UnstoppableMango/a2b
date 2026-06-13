{
  buf,
  env ? { },
  flags ? [ ],
  lib,
  name,
  runCommand,
  src,
}:
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  ${buf}/bin/buf generate ${src} \
    --output "$out" \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
