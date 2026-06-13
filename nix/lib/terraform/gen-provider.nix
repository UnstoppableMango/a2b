{
  command ? "all",
  env ? { },
  flags ? [ ],
  input,
  lib,
  name,
  runCommand,
  terraform-plugin-codegen-framework,
}:

# https://developer.hashicorp.com/terraform/plugin/code-generation/framework-generator#generate-command
runCommand name env ''
  runHook preRun

  ${terraform-plugin-codegen-framework}/bin/tfplugingen-framework generate \
    ${command} \
    --input ${lib.escapeShellArg (toString input)} \
    --output "$out" \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
