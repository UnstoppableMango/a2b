{ lib, runCommand }:
{
  env ? { },
  flags ? [ ],
  language,
  name,
  tfgen,
  tfgenExe ? lib.getExe tfgen,
}:

# https://github.com/pulumi/pulumi-terraform-bridge/blob/master/pkg/tfgen/main.go
# language: nodejs, python, go, dotnet, java
runCommand name env ''
  runHook preRun

  mkdir -p "$out"
  ${tfgenExe} ${lib.escapeShellArg language} \
    --out "$out" \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
