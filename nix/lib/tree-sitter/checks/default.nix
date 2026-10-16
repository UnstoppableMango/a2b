{
  a2b,
  runCommand,
}:
let
  inherit (a2b) tree-sitter;

  input = ./input.pairs;

  generated = tree-sitter.generate {
    grammarPath = "${./grammar}/src/grammar.json";
  };

  # A grammar repository as tree-sitter expects it: the checked-in sources
  # with the generated parser next to them.
  grammar = runCommand "tree-sitter-check-grammar" { } ''
    cp -r ${./grammar} $out
    chmod -R u+w $out
    cp -r ${generated}/. $out/src/
  '';

  parser = tree-sitter.build {
    grammarPath = "${grammar}";
  };

  parsed = tree-sitter.parse {
    libPath = parser;
    langName = "pairs";
    paths = [ "${input}" ];
  };

  queried = tree-sitter.query {
    libPath = parser;
    langName = "pairs";
    queryPath = "${./keys.scm}";
    paths = [ "${input}" ];
  };

  highlighted = tree-sitter.highlight {
    grammarPath = "${grammar}";
    html = true;
    paths = [ "${input}" ];
  };

  initialized = tree-sitter.init {
    grammarPath = "${grammar}";
  };
in
runCommand "tree-sitter-check" { } ''
  fail() {
    echo "$1" >&2
    exit 1
  }

  [ -f ${generated}/parser.c ] || fail "generate produced no parser.c"
  [ -f ${generated}/node-types.json ] || fail "generate produced no node-types.json"
  [ -s ${parser} ] || fail "build produced no shared library"

  grep -q 'key: (word' ${parsed} || fail "parse output is missing the key field"
  [ "$(grep -c '(pair' ${parsed})" = 2 ] || fail "parse did not find both pairs"

  grep -q 'text: `a`' ${queried} || fail "query did not capture the first key"
  grep -q 'text: `c`' ${queried} || fail "query did not capture the second key"
  ! grep -q 'text: `b`' ${queried} || fail "query captured a value"

  grep -q '<span' ${highlighted} || fail "highlight produced no highlighted spans"

  [ -f ${initialized}/grammar.js ] || fail "init produced no grammar.js"
  [ -d ${initialized}/bindings ] || fail "init produced no bindings"

  touch "$out"
''
