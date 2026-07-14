{
  lib,
  pulumi,
  runCommand,
}:
{
  env ? { },
  flags ? [ ],
  from ? null,
  generateOnly ? true,
  language,
  name,
  src,
}:

# https://www.pulumi.com/docs/iac/cli/commands/pulumi_convert/
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  cp -r ${lib.escapeShellArg (toString src)} ./src
  chmod -R u+w ./src

  ${pulumi}/bin/pulumi convert \
    --cwd ./src \
    --language ${lib.escapeShellArg language} \
    --out "$out" \
    ${lib.a2b.cli.optionalArg "from" from} \
    ${lib.a2b.cli.boolArg "generate-only" generateOnly} \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
