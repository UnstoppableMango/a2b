{
  config ? null,
  env ? { },
  flags ? [ ],
  lib,
  name,
  runCommand,
  openapi-spec,
  terraform-plugin-codegen-openapi,
}:

# https://developer.hashicorp.com/terraform/plugin/code-generation/openapi-generator#usage
let
  configFlag = lib.optionalString (config != null) "--config ${lib.escapeShellArg (toString config)}";
in
runCommand name env ''
  runHook preRun

  ${terraform-plugin-codegen-openapi}/bin/tfplugingen-openapi generate \
    ${configFlag} \
    --output "$out" \
    ${lib.escapeShellArgs flags} \
    ${lib.escapeShellArg (toString openapi-spec)}

  runHook postRun
''
