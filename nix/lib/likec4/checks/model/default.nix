{
  a2b,
  jq,
  runCommand,
}:
let
  inherit (a2b) likec4;

  src = ./src;

  site = likec4.build {
    name = "likec4-site";
    inherit src;
    base = "./";
    useHashHistory = true;
  };

  singleFile = likec4.build {
    name = "likec4-single-file";
    inherit src;
    outputSingleFile = true;
  };

  json = likec4.exportJson {
    name = "likec4-json";
    inherit src;
  };

  mermaid = likec4.codegen {
    name = "likec4-mermaid";
    inherit src;
    format = "mermaid";
  };

  webcomponent = likec4.codegen {
    name = "likec4-webcomponent";
    inherit src;
    format = "webcomponent";
  };

  valid = likec4.validate {
    name = "likec4-validate";
    inherit src;
  };
in
runCommand "likec4-model-check" { nativeBuildInputs = [ jq ]; } ''
  fail() {
    echo "$1" >&2
    exit 1
  }

  [ -f ${site}/index.html ] || fail "build produced no index.html"
  [ -d ${site}/assets ] || fail "build produced no assets"
  [ ! -d ${singleFile}/assets ] || fail "single file build emitted separate assets"
  [ -f ${singleFile}/index.html ] || fail "single file build produced no index.html"

  jq -e '.elements.app' ${json} >/dev/null \
    || fail "exported JSON is missing element app"

  [ -f ${mermaid}/index.mmd ] || fail "mermaid codegen produced no index.mmd"
  [ -f ${webcomponent}/likec4-views.js ] || fail "webcomponent codegen produced no likec4-views.js"
  [ -e ${valid} ] || fail "validate produced no output"

  touch "$out"
''
