{
  branch ? null,
  cli,
  env ? { },
  extraArgs ? [ ],
  fluxcd,
  interval ? null,
  lib,
  name,
  namespace ? null,
  runCommand,
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
