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
  export HOME=$(mktemp -d)
  ${gossamer}/bin/gos run ${scriptFile}
''
