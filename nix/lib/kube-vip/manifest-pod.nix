{
  kube-vip,
  lib,
  runCommand,
}:
{
  address,
  env ? { },
  extraArgs ? [ ],
  interface,
  name ? "kube-vip-manifest-pod",
}:
runCommand name env ''
  ${kube-vip}/bin/kube-vip manifest pod \
    --interface ${lib.escapeShellArg interface} \
    --address ${lib.escapeShellArg address} \
    ${lib.escapeShellArgs extraArgs} \
    > $out
''
