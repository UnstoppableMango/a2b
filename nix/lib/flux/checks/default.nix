{
  a2b,
  runCommand,
  yq-go,
}:
let
  components = a2b.flux.gotkComponents {
    url = "https://github.com/example/fleet";
    branch = "main";
    path = "./clusters/test";
    components = [
      "source-controller"
      "kustomize-controller"
    ];
  };
in
runCommand "flux-check" { nativeBuildInputs = [ yq-go ]; } ''
  fail() {
    echo "$1" >&2
    exit 1
  }

  for f in gotk-components.yaml gotk-sync.yaml kustomization.yaml; do
    [ -f ${components}/$f ] || fail "gotkComponents produced no $f"
  done

  yq -e 'select(.kind == "Deployment" and .metadata.name == "source-controller")' \
    ${components}/gotk-components.yaml >/dev/null \
    || fail "install is missing source-controller"
  ! yq -e 'select(.kind == "Deployment" and .metadata.name == "helm-controller")' \
    ${components}/gotk-components.yaml >/dev/null 2>&1 \
    || fail "install includes a component that was not asked for"

  yq -e 'select(.kind == "GitRepository" and .spec.url == "https://github.com/example/fleet" and .spec.ref.branch == "main")' \
    ${components}/gotk-sync.yaml >/dev/null \
    || fail "sync is missing the GitRepository"
  yq -e 'select(.kind == "Kustomization" and .spec.path == "./clusters/test" and .spec.sourceRef.name == "flux-system")' \
    ${components}/gotk-sync.yaml >/dev/null \
    || fail "sync is missing the Kustomization"

  touch "$out"
''
