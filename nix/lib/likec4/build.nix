# Static website with every view of a LikeC4 workspace, ready for any static host.
{
  cli,
  lib,
  likec4,
  runCommand,
}:
{
  base ? null,
  env ? { },
  flags ? [ ],
  name,
  outputSingleFile ? false,
  public ? null,
  src,
  theme ? null,
  title ? null,
  useHashHistory ? false,
}:
runCommand name env ''
  runHook preBuild

  export HOME="$(mktemp -d)"
  ${likec4}/bin/likec4 build \
    ${cli.optionalArg "base" base} \
    ${lib.optionalString useHashHistory "--use-hash-history"} \
    ${lib.optionalString outputSingleFile "--output-single-file"} \
    ${cli.optionalArg "public" public} \
    ${cli.optionalArg "theme" theme} \
    ${cli.optionalArg "title" title} \
    --output $out \
    ${lib.escapeShellArgs flags} \
    ${lib.escapeShellArg "${src}"}

  runHook postBuild
''
