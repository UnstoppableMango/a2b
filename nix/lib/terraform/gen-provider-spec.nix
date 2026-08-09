{
  lib,
  runCommand,
  terraform-plugin-codegen-openapi,
}:
{
  config ? null,
  env ? { },
  flags ? [ ],
  name,
  openapi-spec,
}:

# https://developer.hashicorp.com/terraform/plugin/code-generation/openapi-generator#usage
runCommand name env ''
  runHook preRun

  ${terraform-plugin-codegen-openapi}/bin/tfplugingen-openapi generate \
    ${lib.a2b.cli.optionalArg "config" config} \
    --output "$out" \
    ${lib.escapeShellArgs flags} \
    ${lib.escapeShellArg "${openapi-spec}"}

  runHook postRun
''
