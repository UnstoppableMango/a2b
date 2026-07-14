{
  lib,
  pulumi,
  runCommand,
}:
{
  env ? { },
  flags ? [ ],
  language ? null,
  languages ? [ ],
  name,
  schema,
  version ? null,
}:

# https://www.pulumi.com/docs/iac/cli/commands/pulumi_package_gen-sdk/
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"

  ${pulumi}/bin/pulumi package gen-sdk \
    --out "$out" \
    ${lib.a2b.cli.optionalArg "language" language} \
    ${lib.a2b.cli.optionalArg "version" version} \
    ${lib.a2b.cli.repeatArg "language" languages} \
    ${lib.escapeShellArgs flags} \
    ${lib.escapeShellArg (toString schema)}

  runHook postRun
''
