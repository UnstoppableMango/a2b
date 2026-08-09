{
  cli,
  env ? { },
  file ? null,
  flags ? [ ],
  gossamer,
  lib,
  locked ? false,
  name,
  release ? false,
  runCommand,
  src,
  target ? null,
}:
runCommand name env ''
  runHook preBuild

  cp -r ${src} source
  chmod -R u+w source
  cd source
  export HOME="$(mktemp -d)"
  mkdir -p $out/bin
  ${gossamer}/bin/gos build \
    ${lib.optionalString release "--release"} \
    ${lib.optionalString locked "--locked"} \
    ${cli.optionalArg "target" target} \
    --out-dir $out/bin \
    ${lib.escapeShellArgs flags} \
    ${lib.optionalString (file != null) (lib.escapeShellArg (toString file))}

  runHook postBuild
''
