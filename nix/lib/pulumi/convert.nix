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
  plugins ? [ ],
  src,
}:

# https://www.pulumi.com/docs/iac/cli/commands/pulumi_convert/
# `plugins` should contain any `pulumi-converter-<from>` binaries needed for
# the source ecosystem (none are packaged in nixpkgs) plus, if `--generate-only`
# is disabled, the target `pulumi-language-<language>` plugin.
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  export PATH="${lib.makeBinPath plugins}:$PATH"
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
