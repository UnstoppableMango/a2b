# Fails on syntax, reference, and layout errors. Suits `checks`.
{
  cli,
  lib,
  likec4,
  runCommand,
}:
{
  env ? { },
  files ? [ ],
  flags ? [ ],
  layout ? true,
  name,
  project ? null,
  src,
}:
runCommand name env ''
  runHook preCheck

  export HOME="$(mktemp -d)"
  ${likec4}/bin/likec4 validate \
    ${cli.optionalArg "project" project} \
    ${cli.repeatArg "file" files} \
    ${lib.optionalString (!layout) "--no-layout"} \
    ${lib.escapeShellArgs flags} \
    ${lib.escapeShellArg "${src}"}
  touch $out

  runHook postCheck
''
