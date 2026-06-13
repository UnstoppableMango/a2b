{
  command ? "all",
  env ? { },
  flags ? [ ],
  lib,
  name,
  runCommand,
  terraform-plugin-codegen-framework,
  input,
}:
runCommand name env ''
  runHook preRun

  ${terraform-plugin-codegen-framework}/bin/tfplugingen-framework generate \
    ${command} \
    ${lib.escapeShellArg (toString input)}
    --output "$out" \
    ${lib.escapeShellArgs flags} \

  runHook postRun
''
