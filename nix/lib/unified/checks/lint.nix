# lint passes a clean tree with the default preset, and fails one that breaks
# a rule, naming the rule.
{
  a2b,
  runCommand,
  testers,
  unifiedPackages,
}:
let
  clean = a2b.unified.lint {
    name = "unified-lint-clean";
    src = ./fixture-lint/clean;
    plugins = with unifiedPackages; [
      remark-gfm
      remark-preset-lint-recommended
    ];
  };

  dirty = testers.testBuildFailure (
    a2b.unified.lint {
      name = "unified-lint-dirty";
      src = ./fixture-lint/dirty;
    }
  );
in
runCommand "unified-lint-check" { } ''
  # Nothing to report on the clean tree.
  [ ! -s ${clean} ] || {
    echo "expected an empty report, got:" >&2
    cat ${clean} >&2
    exit 1
  }

  grep -qF 'no-unused-definitions' ${dirty}/testBuildFailure.log || {
    echo "expected no-unused-definitions, got:" >&2
    cat ${dirty}/testBuildFailure.log >&2
    exit 1
  }

  touch "$out"
''
