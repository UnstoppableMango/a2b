# mdx compiles each .mdx file to JavaScript in place in the tree, with a remark
# plugin loaded from its store path and compile options passed through.
{
  a2b,
  runCommand,
  unifiedPackages,
}:
let
  compiled = a2b.unified.mdx {
    name = "unified-mdx-check";
    src = ./fixture-mdx;
    remarkPlugins = [ unifiedPackages.remark-gfm ];
    options.jsx = true;
  };
in
runCommand "unified-mdx-check" { } ''
  expect() {
    grep -qF -- "$2" "$1" || {
      echo "expected '$2' in $1, got:" >&2
      cat "$1" >&2
      exit 1
    }
  }

  # remark-gfm ran: without it the strikethrough stays literal text.
  expect ${compiled}/a.js '<_components.del>'
  # jsx = true keeps JSX in the output.
  expect ${compiled}/a.js '<Note>'
  expect ${compiled}/sub/b.js 'https://example.com'
  # Only .mdx is compiled by default, and sources are not copied.
  [ ! -e ${compiled}/skip.js ] && [ ! -e ${compiled}/a.mdx ] || {
    echo "unexpected files in output:" >&2
    find ${compiled} >&2
    exit 1
  }

  touch "$out"
''
