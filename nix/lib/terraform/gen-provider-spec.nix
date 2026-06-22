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
runCommand name env ''
  runHook preRun

  mkdir -p "$out"
  ${terraform-plugin-codegen-openapi}/bin/tfplugingen-openapi generate \
    ${lib.a2b.cli.optionalArg "config" config} \
    --output "$out" \
    ${lib.escapeShellArgs flags} \
    ${lib.escapeShellArg (toString openapi-spec)}

  runHook postRun
''
