{
  command ? "data-source",
  env ? { },
  flags ? [ ],
  lib,
  name,
  package ? null,
  runCommand,
  scaffoldName ? name,
  terraform-plugin-codegen-framework,
}:

# https://developer.hashicorp.com/terraform/plugin/code-generation/framework-generator#scaffold-command
let
  snakeName = lib.a2b.strings.toSnakeCase scaffoldName;
in
runCommand name env ''
  runHook preRun

  mkdir -p "$out"
  ${terraform-plugin-codegen-framework}/bin/tfplugingen-framework scaffold \
    ${command} \
    --name ${lib.escapeShellArg snakeName} \
    --output-dir "$out" \
    ${lib.a2b.cli.optionalArg "package" package} \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
