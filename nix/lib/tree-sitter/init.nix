{
  lib,
  runCommand,
  tree-sitter,
}:
{
  env ? { },
  grammarPath,
  update ? null,
}:
let
  boolFlag = name: val: lib.optionalString (val != null) "--${name}";

  updateArg = boolFlag "update" update;
in
# init scaffolds bindings into the grammar directory in place, and only runs
# unattended when that directory already has a tree-sitter.json.
runCommand "tree-sitter-init" env ''
  runHook preRun

  export HOME="$(mktemp -d)"

  cp -r ${lib.escapeShellArg "${grammarPath}"} $out
  chmod -R u+w $out

  ${tree-sitter}/bin/tree-sitter init \
    ${updateArg} \
    --grammar-path $out

  runHook postRun
''
