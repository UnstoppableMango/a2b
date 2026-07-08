{
  lib,
  runCommand,
  tree-sitter,
}:
{
  env ? { },
  grammarPath ? null,
}:
let
  grammarPathArg = lib.optionalString (
    grammarPath != null
  ) "--grammar-path ${lib.escapeShellArg grammarPath}";
in
runCommand "tree-sitter-playground" env ''
  runHook preRun

  export HOME="$(mktemp -d)"

  ${tree-sitter}/bin/tree-sitter playground \
    ${grammarPathArg} \
    --export $out

  runHook postRun
''
