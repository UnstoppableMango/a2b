# Proves plugins load by absolute store path inside the sandbox. remark-gfm is
# the witness: without it remark leaves `www.example.com` as plain text and
# escapes the table.
{
  a2b,
  runCommand,
  unifiedPackages,
}:
let
  run = a2b.unified.run {
    name = "unified-run-check";
    src = ./fixture;
    plugins = [
      [
        unifiedPackages.remark-gfm
        { tablePipeAlign = false; }
      ]
    ];
    settings.bullet = "-";
  };
in
runCommand "unified-run-check" { } ''
  expect() {
    if ! grep -qF -- "$2" "$1"; then
      echo "expected '$2' in $1, got:" >&2
      cat "$1" >&2
      exit 1
    fi
  }

  # The plugin ran, with its options.
  expect ${run}/a.md '[www.example.com](http://www.example.com)'
  expect ${run}/a.md '| 1 | 2 |'
  # settings reached remark-stringify.
  expect ${run}/a.md '- one'
  # The tree keeps its layout.
  expect ${run}/sub/b.md '[www.example.org](http://www.example.org)'

  touch "$out"
''
