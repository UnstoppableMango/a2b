# Proves plugins load by absolute store path inside the sandbox, through both
# unifiedRun and remark-cli.withPlugins. remark-gfm is the witness: without it
# remark leaves `www.example.com` as plain text and escapes the table.
{
  lib,
  runCommand,
  unifiedPackages,
}:
let
  inherit (unifiedPackages) remark-cli remark-gfm unifiedRun;

  run = unifiedRun {
    name = "unified-run-check";
    src = ./fixture;
    plugins = [
      [
        remark-gfm
        { tablePipeAlign = false; }
      ]
    ];
    settings.bullet = "-";
  };

  remark = remark-cli.withPlugins (ps: [ ps.remark-gfm ]);
in
{
  run = runCommand "unified-run-check" { } ''
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
  '';

  remark-with-plugins = runCommand "remark-with-plugins-check" { } ''
    echo 'www.example.com' | ${lib.getExe remark} --no-color > out.md
    if ! grep -qF '[www.example.com](http://www.example.com)' out.md; then
      echo "withPlugins did not load remark-gfm, got:" >&2
      cat out.md >&2
      exit 1
    fi

    touch "$out"
  '';

  remark-cli-version = remark-cli.tests.version;
}
