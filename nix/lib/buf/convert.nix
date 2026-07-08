{ buf, runCommand }:
{
  env ? { },
  from ? "",
  input ? "",
  name,
  to,
  type,
}:
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  ${buf}/bin/buf convert ${input} \
    --type=${type} \
    --from=${from} \
    --to=${to}

  runHook postRun
''
