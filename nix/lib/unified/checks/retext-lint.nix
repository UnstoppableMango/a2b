# retextLint passes clean prose with the default plugins, and fails a repeated
# word, naming the rule.
{
  a2b,
  runCommand,
  testers,
}:
let
  clean = a2b.unified.retextLint {
    name = "unified-retext-lint-clean";
    src = ./fixture-retext-lint/clean;
  };

  dirty = testers.testBuildFailure (
    a2b.unified.retextLint {
      name = "unified-retext-lint-dirty";
      src = ./fixture-retext-lint/dirty;
    }
  );
in
runCommand "unified-retext-lint-check" { } ''
  [ ! -s ${clean} ] || {
    echo "expected an empty report, got:" >&2
    cat ${clean} >&2
    exit 1
  }

  grep -qF 'retext-repeated-words' ${dirty}/testBuildFailure.log || {
    echo "expected retext-repeated-words, got:" >&2
    cat ${dirty}/testBuildFailure.log >&2
    exit 1
  }

  touch "$out"
''
