# rehype runs rehype-cli rather than remark-cli, and settings reach
# rehype-stringify.
{ a2b, runCommand }:
let
  run = a2b.unified.rehype {
    name = "unified-rehype-check";
    src = ./fixture-html;
    settings.quote = "'";
  };
in
runCommand "unified-rehype-check" { } ''
  grep -qF "<p class='a'>b</p>" ${run}/index.html || {
    echo "expected single quotes, got:" >&2
    cat ${run}/index.html >&2
    exit 1
  }
  touch "$out"
''
