# Vendor .proto files into a tree matching their import paths: `root` strips a
# prefix from the source layout, `prefix` prepends one to the result.
{
  lib,
  runCommand,
}:
{
  env ? { },
  excludes ? [ ],
  includes ? [ "." ],
  name,
  prefix ? "",
  root ? ".",
  src,
}:
let
  # find echoes its roots verbatim, so "./." yields "././foo" and never matches
  # a "-path ./foo" prune.
  cleanPath = p: if p == "." || p == "./" then "." else "./" + lib.removePrefix "./" p;

  includeArgs = lib.escapeShellArgs (map cleanPath includes);

  pruneArgs = lib.optionalString (excludes != [ ]) (
    "\\( "
    + lib.concatMapStringsSep " -o " (p: "-path ${lib.escapeShellArg (cleanPath p)}") excludes
    + " \\) -prune -o"
  );
in
runCommand name env ''
  runHook preRun

  dest="$out/${prefix}"
  mkdir -p "$dest"
  cd ${src}/${root}

  found=0
  while IFS= read -r -d "" f; do
    # -m644 drops the read-only store mode.
    install -Dm644 "$f" "$dest/$f"
    found=1
  done < <(find ${includeArgs} ${pruneArgs} -name '*.proto' -type f -print0)

  if [ "$found" -eq 0 ]; then
    echo "buf.vendor: no .proto files found under ${root}" >&2
    exit 1
  fi

  runHook postRun
''
