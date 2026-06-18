{
  env ? { },
  grammarPath ? null,
  lib,
  runCommand,
  tree-sitter,
  update ? null,
}:
let
  boolFlag = name: val: lib.optionalString (val != null) "--${name}";
  valFlag =
    name: val: lib.optionalString (val != null) "--${name} ${lib.escapeShellArg (toString val)}";

  updateArg = boolFlag "update" update;
  grammarPathArg = valFlag "grammar-path" grammarPath;
in
runCommand "tree-sitter-init" env ''
  runHook preRun

  export HOME="$(mktemp -d)"

  ${tree-sitter}/bin/tree-sitter init \
    ${updateArg} \
    ${grammarPathArg}

  runHook postRun
''
