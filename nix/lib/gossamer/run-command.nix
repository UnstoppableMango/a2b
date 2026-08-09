{
  env ? { },
  gossamer,
  name,
  runCommand,
  script,
  writeText,
}:
let
  scriptFile = writeText "${name}.gos" script;
in
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  ${gossamer}/bin/gos run ${scriptFile}

  if [ ! -e "$out" ]; then
    touch "$out"
  fi

  runHook postRun
''
