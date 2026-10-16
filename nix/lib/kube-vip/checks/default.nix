{
  a2b,
  runCommand,
  yq-go,
}:
let
  pod = a2b.kube-vip.manifestPod {
    interface = "eth0";
    address = "192.168.1.10";
    extraArgs = [ "--controlplane" ];
  };
in
runCommand "kube-vip-check" { nativeBuildInputs = [ yq-go ]; } ''
  fail() {
    echo "$1" >&2
    exit 1
  }

  [ "$(yq '.kind' ${pod})" = Pod ] || fail "manifest is not a Pod"
  yq -e '.spec.containers[0].env[] | select(.name == "address" and .value == "192.168.1.10")' ${pod} >/dev/null \
    || fail "manifest is missing the address"
  yq -e '.spec.containers[0].env[] | select(.name == "vip_interface" and .value == "eth0")' ${pod} >/dev/null \
    || fail "manifest is missing the interface"

  touch "$out"
''
