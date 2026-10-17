{
  a2b,
  go,
  runCommand,
}:
let
  generated = a2b.openapi2go.generate {
    name = "openapi2go-petstore";
    src = ./spec.yaml;
    packageName = "petstore";
  };
in
runCommand "openapi2go-check" { nativeBuildInputs = [ go ]; } ''
  fail() {
    echo "$1" >&2
    exit 1
  }

  file=${generated}/openapi2go.zz_generated.go
  [ -f "$file" ] || fail "generate produced no openapi2go.zz_generated.go"
  grep -q '^package petstore$' "$file" || fail "generated file is not in package petstore"
  grep -q '^type Pet struct' "$file" || fail "generated file has no Pet struct"

  export HOME="$(mktemp -d)" GOCACHE="$(mktemp -d)"
  cp "$file" ./pet.go
  go vet ./pet.go || fail "generated file does not compile"

  touch "$out"
''
