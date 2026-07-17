{ lib, runCommand }:
{
  env ? { },
  flags ? [ ],
  name,
  tfgen,
  tfgenExe ? lib.getExe tfgen,
}:

# https://github.com/pulumi/pulumi-terraform-bridge/blob/master/pkg/tfgen/main.go
runCommand name env ''
  runHook preRun

  mkdir -p "$out"
  ${tfgenExe} schema \
    --out "$out" \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
