{
  a2b,
  runCommand,
  typescript,
}:
let
  types = a2b.typescript.openapi-typescript {
    name = "petstore.d.ts";
    src = ./petstore.yaml;
  };
in
runCommand "typescript-check" { nativeBuildInputs = [ typescript ]; } ''
  fail() {
    echo "$1" >&2
    exit 1
  }

  grep -q 'Pet: {' ${types} || fail "types are missing the Pet schema"
  grep -q '"/pets/{id}"' ${types} || fail "types are missing the /pets/{id} path"
  grep -q 'getPet' ${types} || fail "types are missing the getPet operation"

  # The generated types have to compile, and the schema has to mean what it says.
  cp ${types} schema.d.ts
  cat > use.ts <<'TS'
  import type { components } from "./schema";
  type Pet = components["schemas"]["Pet"];
  const pet: Pet = { id: 1, name: "rex" };
  // @ts-expect-error name is required
  const nameless: Pet = { id: 2 };
  export { pet, nameless };
  TS
  tsc --strict --noEmit schema.d.ts use.ts || fail "generated types do not type-check"

  touch "$out"
''
