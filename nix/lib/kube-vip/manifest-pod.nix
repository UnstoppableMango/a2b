{
  address,
  env ? { },
  extraArgs ? [ ],
  interface,
  kube-vip,
  lib,
  name ? "kube-vip-manifest-pod",
  runCommand,
}:
runCommand name env ''
  ${kube-vip}/bin/kube-vip manifest pod \
    --interface ${lib.escapeShellArg interface} \
    --address ${lib.escapeShellArg address} \
    ${lib.escapeShellArgs extraArgs} \
    > $out
''
