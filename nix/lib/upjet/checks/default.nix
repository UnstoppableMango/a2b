{
  a2b,
  runCommand,
}:
let
  # genProvider needs gomod2nix's buildGoApplication, which needs IFD, so only
  # the template is checked here.
  template = a2b.upjet.genProviderTemplate {
    providerName = "Random";
    organizationName = "example";
    terraformProviderVersion = "3.6.3";
    version = "0.1.0";

    # Only reached through passthru.update-deps, which this check never forces.
    mangoTools = throw "mangoTools is not needed to build the template";
  };
in
runCommand "upjet-check" { } ''
  fail() {
    echo "$1" >&2
    exit 1
  }

  [ -f ${template}/go.mod ] || fail "template has no go.mod"
  grep -q 'provider-random' ${template}/go.mod || fail "template module was not renamed"
  grep -q 'export TERRAFORM_PROVIDER_VERSION ?= 3.6.3' ${template}/Makefile \
    || fail "template Makefile does not pin the provider version"
  ! grep -rq '@TERRAFORM_' ${template}/Makefile || fail "template Makefile has unsubstituted variables"
  [ ! -d ${template}/internal/controller/cluster/null ] || fail "template still has the null controller"

  touch "$out"
''
