# retext runs retext-cli rather than remark-cli, over .txt files, with a
# plugin named by path rather than by derivation.
{ a2b, runCommand }:
let
  run = a2b.unified.retext {
    name = "unified-retext-check";
    src = ./fixture-retext;
    plugins = [ ./fixture-retext/upper.js ];
  };
in
runCommand "unified-retext-check" { } ''
  expect() {
    grep -qF -- "$2" "$1" || {
      echo "expected '$2' in $1, got:" >&2
      cat "$1" >&2
      exit 1
    }
  }

  expect ${run}/a.txt 'HELLO THERE, WORLD.'
  expect ${run}/sub/b.txt 'SECOND FILE.'

  touch "$out"
''
