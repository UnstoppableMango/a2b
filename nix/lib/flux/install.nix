{
  components ? null,
  componentsExtra ? null,
  env ? { },
  extraArgs ? [ ],
  fluxcd,
  lib,
  name ? "flux-install",
  namespace ? null,
  runCommand,
}:
runCommand name env ''
  ${fluxcd}/bin/flux install \
    --export \
    ${lib.optionalString (namespace != null) "--namespace=${lib.escapeShellArg namespace}"} \
    ${
      lib.optionalString (
        components != null
      ) "--components=${lib.escapeShellArg (lib.concatStringsSep "," components)}"
    } \
    ${
      lib.optionalString (
        componentsExtra != null
      ) "--components-extra=${lib.escapeShellArg (lib.concatStringsSep "," componentsExtra)}"
    } \
    ${lib.escapeShellArgs extraArgs} \
    > $out
''
