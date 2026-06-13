{
  command ? "data-source",
  env ? { },
  flags ? [ ],
  input,
  lib,
  name,
  runCommand,
  terraform-plugin-codegen-framework,
}:
runCommand name env ''
  runHook preRun

  ${terraform-plugin-codegen-framework}/bin/tfplugingen-framework generate \
    ${command} \
    --input ${lib.escapeShellArg (toString input)} \
    --output "$out" \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
