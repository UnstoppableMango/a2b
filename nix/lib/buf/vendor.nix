# Vendor .proto files from an external source into an import-path-correct tree.
#
# Buf resolves imports by path relative to a module root, so vendored protos must
# live at exactly the path their importers reference. `root` strips a prefix from
# the source layout, `prefix` prepends one to the result; the two compose.
#
# Example: the kubernetes/api repo root is the import prefix `k8s.io/api`:
#   buf.vendor {
#     name = "k8s-api-protos";
#     prefix = "k8s.io/api";
#     src = fetchFromGitHub { owner = "kubernetes"; repo = "api"; ... };
#   }
#
# Example: the kubernetes monorepo is already laid out as k8s.io/... under staging/src:
#   buf.vendor {
#     name = "k8s-protos";
#     root = "staging/src";
#     src = fetchFromGitHub { owner = "kubernetes"; repo = "kubernetes"; ... };
#   }
#
# Pass the result to `buf.mkWorkspace` as a module to make it importable.
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
  # find prints results under the roots it was given verbatim, so a root of "./."
  # yields "././foo" and never matches a "-path ./foo" prune. Normalize both
  # sides to the same "." / "./foo" form.
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
    # -D creates parent directories, -m644 drops the read-only store mode.
    install -Dm644 "$f" "$dest/$f"
    found=1
  done < <(find ${includeArgs} ${pruneArgs} -name '*.proto' -type f -print0)

  if [ "$found" -eq 0 ]; then
    echo "buf.vendor: no .proto files found under ${root}" >&2
    exit 1
  fi

  runHook postRun
''
