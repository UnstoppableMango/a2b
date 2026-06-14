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
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  ${buf}/bin/buf generate "${src}" \
    --output "$out" \
    ${if template != null then "--template \"${template}\"" else ""} \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
