{
  dependsOn ? [ ],
  env ? { },
  extraArgs ? [ ],
  fluxcd,
  interval ? null,
  lib,
  name,
  namespace ? null,
  path,
  prune ? null,
  runCommand,
  source,
  targetNamespace ? null,
}:
runCommand "flux-kustomization-${name}" env ''
  ${fluxcd}/bin/flux create kustomization ${lib.escapeShellArg name} \
    --source=${lib.escapeShellArg source} \
    --path=${lib.escapeShellArg path} \
    ${lib.optionalString (prune != null) "--prune=${lib.boolToString prune}"} \
    ${lib.optionalString (interval != null) "--interval=${lib.escapeShellArg interval}"} \
    ${lib.optionalString (namespace != null) "--namespace=${lib.escapeShellArg namespace}"} \
    ${
      lib.optionalString (
        targetNamespace != null
      ) "--target-namespace=${lib.escapeShellArg targetNamespace}"
    } \
    ${lib.concatMapStringsSep " " (d: "--depends-on=${lib.escapeShellArg d}") dependsOn} \
    --export \
    ${lib.escapeShellArgs extraArgs} \
    > $out
''
