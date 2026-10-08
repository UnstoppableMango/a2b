# The whole model as JSON, for checks and tooling that read the architecture.
{
  cli,
  lib,
  likec4,
  runCommand,
}:
{
  env ? { },
  flags ? [ ],
  name,
  pretty ? false,
  project ? null,
  skipLayout ? false,
  src,
}:
runCommand name env ''
  runHook preBuild

  export HOME="$(mktemp -d)"
  # likec4 appends .json to an outfile without the extension.
  ${likec4}/bin/likec4 export json \
    ${cli.optionalArg "project" project} \
    ${lib.optionalString pretty "--pretty"} \
    ${lib.optionalString skipLayout "--skip-layout"} \
    --outfile model.json \
    ${lib.escapeShellArgs flags} \
    ${lib.escapeShellArg "${src}"}
  mv model.json $out

  runHook postBuild
''
