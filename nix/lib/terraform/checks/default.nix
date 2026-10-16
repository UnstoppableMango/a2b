{
  a2b,
  jq,
  runCommand,
}:
let
  inherit (a2b) terraform;

  spec = terraform.genProviderSpec {
    name = "terraform-check-spec";
    config = ./generator-config.yaml;
    openapi-spec = ./petstore.yaml;
  };

  provider = terraform.genProvider {
    name = "terraform-check-provider";
    input = spec;
  };

  scaffold = terraform.scaffold {
    name = "terraform-check-scaffold";
    scaffoldName = "petOwner";
    package = "provider";
  };
in
runCommand "terraform-check" { nativeBuildInputs = [ jq ]; } ''
  fail() {
    echo "$1" >&2
    exit 1
  }

  jq -e '.provider.name == "petstore"' ${spec} >/dev/null || fail "spec is missing the provider"
  jq -e '.resources[] | select(.name == "pet")' ${spec} >/dev/null || fail "spec is missing the pet resource"
  jq -e '.datasources[] | select(.name == "pet")' ${spec} >/dev/null || fail "spec is missing the pet data source"

  find ${provider} -name '*.go' | grep -q . || fail "genProvider produced no Go files"
  grep -rq 'func PetResourceSchema' ${provider} || fail "genProvider is missing the pet resource schema"

  [ -f ${scaffold}/pet_owner_data_source.go ] || fail "scaffold produced no pet_owner_data_source.go"
  grep -q '^package provider$' ${scaffold}/pet_owner_data_source.go || fail "scaffold ignored the package name"

  touch "$out"
''
