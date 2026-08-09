{
  env ? { },
  file ? null,
  flags ? [ ],
  gossamer,
  lib,
  name,
  runCommand,
  src,
}:
runCommand name env ''
  runHook preCheck

  cp -r ${src} source
  chmod -R u+w source
  cd source
  export HOME="$(mktemp -d)"
  ${gossamer}/bin/gos check \
    ${lib.escapeShellArgs flags} \
    ${lib.optionalString (file != null) (lib.escapeShellArg (toString file))}
  echo "ok" > $out

  runHook postCheck
''
