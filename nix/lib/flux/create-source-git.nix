{
  cli,
  fluxcd,
  lib,
  runCommand,
}:
{
  branch ? null,
  env ? { },
  extraArgs ? [ ],
  interval ? null,
  name,
  namespace ? null,
  semver ? null,
  tag ? null,
  url,
}:
runCommand "flux-source-git-${name}" env ''
  ${fluxcd}/bin/flux create source git ${lib.escapeShellArg name} \
    --url=${lib.escapeShellArg url} \
    ${cli.optionalArg "branch" branch} \
    ${cli.optionalArg "tag" tag} \
    ${cli.optionalArg "tag-semver" semver} \
    ${cli.optionalArg "interval" interval} \
    ${cli.optionalArg "namespace" namespace} \
    --export \
    ${lib.escapeShellArgs extraArgs} \
    > $out
''
