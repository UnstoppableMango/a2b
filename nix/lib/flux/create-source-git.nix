{
  branch ? null,
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
    ${lib.optionalString (branch != null) "--branch=${lib.escapeShellArg branch}"} \
    ${lib.optionalString (tag != null) "--tag=${lib.escapeShellArg tag}"} \
    ${lib.optionalString (semver != null) "--tag-semver=${lib.escapeShellArg semver}"} \
    ${lib.optionalString (interval != null) "--interval=${lib.escapeShellArg interval}"} \
    ${lib.optionalString (namespace != null) "--namespace=${lib.escapeShellArg namespace}"} \
    --export \
    ${lib.escapeShellArgs extraArgs} \
    > $out
''
