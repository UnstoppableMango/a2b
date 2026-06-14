{
  buf,
  env ? { },
  flags ? [ ],
  input,
  name,
  runCommand,
}:
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  ${buf}/bin/buf build ${input} \
    --output $out \
    ${flags}

  runHook postRun
''
