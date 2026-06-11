{
  config ? null,
  env ? { },
  flags ? [ ],
  lib,
  name,
  runCommand,
  src,
  terraform-plugin-codegen-openapi,
}:
let
  configFlag = lib.optionalString (config != null) "--config ${config}";
in
runCommand name env ''
  runHook preRun

  ${terraform-plugin-codegen-openapi}/bin/tfplugingen-openapi generate \
    ${configFlag} \
    --output "$out" \
    ${lib.escapeShellArgs flags} \
    ${src}

  runHook postRun
''
