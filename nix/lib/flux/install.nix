{
  cli,
  fluxcd,
  lib,
  runCommand,
}:
{
  components ? null,
  componentsExtra ? null,
  env ? { },
  extraArgs ? [ ],
  name ? "flux-install",
  namespace ? null,
}:
runCommand name env ''
  ${fluxcd}/bin/flux install \
    --export \
    ${cli.optionalArg "namespace" namespace} \
    ${cli.listArg "components" components} \
    ${cli.listArg "components-extra" componentsExtra} \
    ${lib.escapeShellArgs extraArgs} \
    > $out
''
