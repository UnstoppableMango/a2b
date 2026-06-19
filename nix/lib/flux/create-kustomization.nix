{
  cli,
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
    ${cli.boolArg "prune" prune} \
    ${cli.optionalArg "interval" interval} \
    ${cli.optionalArg "namespace" namespace} \
    ${cli.optionalArg "target-namespace" targetNamespace} \
    ${cli.repeatArg "depends-on" dependsOn} \
    --export \
    ${lib.escapeShellArgs extraArgs} \
    > $out
''
