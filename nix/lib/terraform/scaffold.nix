{
  command ? "data-source",
  env ? { },
  flags ? [ ],
  lib,
  name,
  package ? null,
  runCommand,
  scaffoldName ? name,
  strings,
  terraform-plugin-codegen-framework,
}:

# https://developer.hashicorp.com/terraform/plugin/code-generation/framework-generator#scaffold-command
let
  snakeName = strings.toSnakeCase scaffoldName;

  packageFlag = lib.optionalString (
    package != null
  ) "--package ${lib.escapeShellArg (toString package)}";
in
runCommand name env ''
  runHook preRun

  ${terraform-plugin-codegen-framework}/bin/tfplugingen-framework scaffold \
    ${command} \
    --name ${lib.escapeShellArg snakeName} \
    --output-dir "$out" \
    ${packageFlag} \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
